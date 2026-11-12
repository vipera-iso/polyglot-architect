# Profiling tools per language

`scripts/profile.sh` auto-detects and dispatches. This file explains what
each tool produces and when to use it.

## Rust
- `cargo flamegraph --bin <name> -- <args>` — CPU flamegraph, best start.
- `perf record -g -- <bin>` — Linux perf, fine-grained sampling.
- `heaptrack <bin>` — allocations, peak RSS.
- `cargo bench` / `criterion` — microbenchmarks with statistics.
- `dhat` (crate) — heap profiling in-process.
- `bpftrace` — syscall + kernel-level.

## Go
- `go test -bench=. -benchmem -cpuprofile=cpu.prof`
- `go tool pprof -http=:8080 cpu.prof` — interactive.
- `runtime/trace` — scheduler, goroutine blocking.
- `benchstat` — statistically compare two runs.

## Python
- `py-spy record -o out.svg -- python script.py` — sampling, no code change.
- `cProfile` + `pstats` — deterministic, adds overhead.
- `line_profiler` — per-line in hot functions.
- `memray` — allocation profiler.
- `scalene` — CPU + memory + GPU.

## Node / TypeScript
- `node --prof script.js` + `node --prof-process` — V8 profiler.
- `--cpu-prof`, `--heap-prof` — Chrome DevTools import.
- `clinic` (npm) — flamegraph, bubbleprof, doctor.
- `0x` (npm) — flamegraph.
- `hyperfine` on macro runs.

## Java / Kotlin
- `jfr` (JDK Flight Recorder) — production-safe.
- `async-profiler` — low-overhead sampling, flamegraphs.
- `jcmd <pid> Thread.print` — thread dump.
- JMH for microbenchmarks.

## C# / .NET
- `dotnet-trace` — sampling.
- `dotnet-counters` — runtime counters.
- `perfcollect` (Linux) — perf + managed.
- BenchmarkDotNet for microbenchmarks.

## C / C++
- `perf record -g -- <bin>` — Linux.
- `valgrind --tool=callgrind` — instruction-level (slow).
- `gprof` — older, function-level.
- `gperftools` — heap + CPU.
- `vtune` (Intel) — advanced hardware counters.

## Universal / cross-language
- `hyperfine '<cmd>'` — wall-clock macro, cold vs warm.
- `bpftrace` / `bcc` — kernel-level (syscalls, network).
- `strace -c` — syscall summary.
- `time` / `/usr/bin/time -v` — RSS, page faults.
- `dtrace` (macOS/BSD) — systemwide.

## Reading the output

- **Flat flamegraph** (no wide plateaus) → memory-bound, I/O-bound, or
  distributed. **Do not swap languages** — profile at a different layer.
- **Narrow spike at a leaf** → true hot path, swap candidate.
- **Wide plateau in one module** → dominant unit, prime SWAP candidate.
- **Time distributed across many small functions** → allocation or
  branch-bound; verify leaves first.
- **High syscall time** → I/O-bound; language swap irrelevant.

## What to record for the heat map

- profiler name and version
- number of samples
- % of total time attributed
- mode: cold / warm / hot / stateful
- artifact filename (flamegraph.svg, cpu.prof, etc.)

"no measurement available" is acceptable but must be labeled, and the unit
**cannot** be a SWAP candidate until measured.
