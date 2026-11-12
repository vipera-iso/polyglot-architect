# Worked example — a CPU-first GGUF inference engine

This is a filled-in matrix for an engine whose hot path was measured, not
assumed. The point of the example is how many rows end in KEEP, and how the
one SWAP row is justified by *capability*, not by speed.

## Measured context

- 1.5B model, Q4_K_M, 457-token prompt, 64 generated tokens.
- Load: ~0.43 s. Prefill: ~9.0 s. Decode: ~36 ms/token (q4k 46%, q6k 24%,
  attention 21%).
- Memory bandwidth on the machine: memcpy 42.1 GB/s; the decode loop already
  reaches 31–40 GB/s.

## Decision table

| # | Unit | Current | Proposed | Property that justifies swap | Verdict |
|---|---|---|---|---|---|
| 1 | backend-cpu decode kernel | Rust | Zig | none — bandwidth-bound at 74–95% of memcpy | KEEP |
| 2 | backend-cpu prefill kernel | Rust | Zig | compute-bound, but measured 1.5% (noise) vs Rust tiled, at ~250/282 GFLOPS AVX2 peak | KEEP |
| 3 | server | Rust | Go | HTTP is ~1–3 ms of a >2 s request | KEEP |
| 4 | tokenizer | Rust | Zig | 2–4 ms per request, <0.1% | KEEP |
| 5 | prefill matmul on GPU | — | C++/CUDA | GPU is new hardware capability, not a faster language for the same work | CONSIDER (feature-gated, needs a GPU runner) |

## What the anti-hype pass removed

- **Zig as a component language.** The kernel written in Zig matched the Rust
  tiled path within noise, and the AVX-512 build of the same source ran 14%
  *slower* on the benchmark CPU. Removing Zig loses nothing measurable.
- **Go server.** The server is <1% of wall time; crossing the runtime trait
  would cost more than it saves.
- **Python.** Belongs to the harness outside the shipped binary.

## Surviving architecture

Rust everywhere, plus one optional C++/CUDA backend behind the existing
`ForwardPass` trait, compiled only when the feature is on and entered only
after a runtime device check.

## Go/no-go gates

- Phase 1 (Rust prefill): token-id equality on conformance, ≥1.3x prefill on
  the 457-token prompt.
- Phase 2 (CUDA): conformance on a real GPU runner, greedy token equality,
  and prefill faster than the CPU number on the same box.
- Phase 3: stop. No third language has a measured case.
