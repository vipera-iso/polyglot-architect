# Measurement hygiene

Step 0 in `SKILL.md`. A performance verdict is only as good as the number under it, and most bad
architecture advice is a sound argument built on a number nobody re-ran.

## The checklist

Run this before mapping units, and again before writing the report.

1. **Provenance.** For every figure: measured here / claimed by someone / unknown. Claimed figures
   that survive into the report are labelled `unverified`.
2. **Denominator.** Bytes read is not file size. Cached input is not DRAM. Peak is not datasheet.
3. **Sample size.** N ≥ 5 for a headline number; median plus min/max. Micro-benchmarks may use
   best-of-N, but say which statistic is quoted.
4. **Session.** Never compare a number from today with one from last week on a laptop. Re-measure
   the baseline in the same session, on the same power state.
5. **Attribution.** Before blaming a change, stash it and re-measure. A 5% "regression" is often a
   fast sample in the baseline.
6. **Ceiling.** If the report says "memory-bound" or "% of peak", a ceiling must have been measured
   on this machine (see below).
7. **Spread.** If two identical runs differ by more than ~10%, the machine is governor- or thermally
   limited. Report the spread and rely on medians, not means — one throttled run drags a mean.

## Formulas worth writing down

```text
achieved GB/s      = bytes_moved / seconds
percent_of_ceiling = achieved GB/s / measured_ceiling GB/s
floor_seconds      = bytes_moved / ceiling GB/s        # the best this workload can do here
gap                = rival_throughput / own_throughput
overhead_per_call  = (measured_per_call - bytes_moved / ceiling) / calls
```

Three traps these catch:

- **File size as read set.** A model file includes embedding tables that decode never touches. Divide
  by the tensors actually read, or the bandwidth is overstated by 10-15%.
- **Throughput without bytes/token.** `tok/s` alone cannot be compared with a GB/s ceiling. Convert
  first.
- **Percent of datasheet peak.** 51.2 GB/s of DDR4-3200 is not reachable; the practical read ceiling
  on a laptop is often ~80-85% of it.

## Measuring a ceiling (when none exists)

Do not infer a ceiling from your own kernel. Measure it:

- **STREAM** (McCalpin, official `stream.c`): `Copy` for 1-read-1-write workloads, `Triad` for
  2-read-1-write. Compile with `-O3 -march=native -fopenmp`, set `STREAM_ARRAY_SIZE` so the working
  set is several times L3 (256 MB per array is a safe default), `NTIMES=10`.
- **Read-only kernel**: a weight stream is usually 1 read + a tiny write. Sum an array larger than L3
  with **four independent accumulators** — a single accumulator measures add latency and reports
  ~30% of the real bandwidth. This mistake is easy to make and hard to notice.
- **Threads**: run 4 and 8 (or physical vs logical). SMT commonly adds nothing to a bandwidth stream;
  report which one the number came from.

Quote the practical ceiling in the report, not the datasheet, and say which kernel produced it.

## Worked example (a CPU inference engine)

The review was handed `pp128 47.1 tok/s` and `file size 1.117 GB`, and both went into the first
draft before being checked.

| Claim | Re-measurement | What it changed |
|---|---|---|
| `pp128 47.1` and a 4.7% regression after a change | baseline without the change: 44.4; with: 45.0; both reproduced twice | no regression existed; the "fix" for it was unnecessary |
| 1.117 GB read per token | tensor table 1.111 GB, `token_embd` 125 MB never read → **0.980 GB** | achieved bandwidth 28 GB/s, not 31; gap to the ceiling was 35%, not 27% |
| "at the DRAM wall" | read-only ceiling 42.8 GB/s (STREAM-class, 4 threads); achieved 28.8 at 4 threads | memory-bound, but 33% of headroom left |
| rival baseline from a handoff note | re-ran the rival on this machine: 209 tok/s, not 256 | prefill gap 4.6x, not 5.4x |

Then Step 2b split the hot crate by shape and found what no crate-level table could: the large
tensors were already at 67-83% of the ceiling, and 16% of the step sat in four small tensors at
5-18 GB/s — a per-call dispatch cost, not a language problem.

Lesson: the cheapest repair in a review is verifying the input numbers; the most expensive mistake is
a confident report built on one of them.

## Smells and what they usually mean

| Symptom | Likely cause |
|---|---|
| Identical runs differ >10% | governor / thermal / noisy neighbour — fix measurement before code |
| Large tensors fast, small ones slow | per-call dispatch, allocation, or sync — not bandwidth |
| One thread ≈ N threads per core | per-core ceiling reached; adding threads will not help |
| Kernel fast alone, slow in situ | cache eviction by other phases, or a cold read set |
| Claimed speedup exceeds measured ceiling | the claim is not about this machine or this workload |
| "Language X streams memory faster" | check how each build was compiled; same instruction stream, same bandwidth |
