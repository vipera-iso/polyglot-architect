# Language strengths — match by property, not by reputation

The question is never "which language is fastest". It is "what does this unit
actually spend its cycles on, and which language lets that specific resource be
used best". A unit that is 90% DRAM traffic is a different problem from a unit
that is 90% FLOPs, and both differ from one that is 90% parsing.

## Matching table

| Property the unit actually has | Language that wins | Why | Counter-indication |
|---|---|---|---|
| Dense linear algebra, SIMD, GPU kernels | C / C++ / CUDA, Mojo, Zig (CPU SIMD) | Direct control of vectors, stable ABI, mature BLAS/cuBLAS | Marshalling per call kills the gain if calls are tiny |
| Cold start, binary size, no runtime | Zig, C, Rust | No GC, no interpreter startup, static linking | Ecosystem may lack the libraries the unit needs |
| Tail-latency-sensitive, no GC pauses | Rust, C++, Zig | Deterministic memory, no collector | Manual memory management cost |
| Concurrent request serving, observability | Go, Rust | Cheap goroutines / async, built-in profiling | GC tail latency at high load |
| Glue, tooling, test harness, prototyping | Python | Ecosystem, speed of iteration | Never put Python on the inner loop |
| Sandboxed plugin / portable module | Wasm (Rust/C++ → wasm) | Memory isolation, deterministic | Wasm↔host call overhead |
| Stateful orchestration, ownership-heavy | Rust | Borrow checker prevents aliasing bugs across async state | Verbose for simple data pipelines |
| String-heavy parsing, one-shot | Any; prefer current | Parsing is rarely hot enough to justify FFI | — |

## The two questions to ask before reading the table

1. **Is this unit bandwidth-bound or compute-bound?** Bandwidth-bound work
   gains nothing from a faster instruction set or a language with better code
   generation: the limit is bytes per second from DRAM. Measure the loop
   against `memcpy` on the same machine. If it is above ~70% of memcpy, a
   rewrite in any language is a dead end; the win has to come from reading
   fewer bytes (quantization, fusion, caching).
2. **How much work does one call do?** If a call does less than ~10 µs of
   work and crosses an FFI boundary, the boundary cost is likely ≥10% of the
   call. Coarsen the boundary (batch the calls) or keep the code where it is.

## Rule of thumb

If a call does less than ~10 µs of work and crosses an FFI boundary, the
boundary cost is likely ≥10% of the call. Coarsen or keep.

## What "better language" cannot fix

- DRAM bandwidth ceiling
- Cache misses caused by data layout
- Algorithmic complexity
- Lock contention and scheduling
- Cold-start cost dominated by file I/O and parsing

Each of these looks like a language problem in a profile and is not one.
