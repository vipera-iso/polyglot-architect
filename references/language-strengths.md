# Language strengths — match by property, not reputation

## Property → language matrix

| Property the unit actually has | Language that wins | Why | Counter-indication |
|---|---|---|---|
| Dense linear algebra, SIMD, GPU | C / C++ / CUDA, Zig, Mojo, Rust | Direct vector control, mature BLAS/cuBLAS | Tiny calls kill gain via marshalling |
| Cold start, small binary, no runtime | Zig, C, Rust | No GC, no interpreter, static link | Ecosystem may lack libraries |
| Tail-latency critical, no GC pauses | Rust, C++, Zig | Deterministic memory | Manual memory cost |
| High-concurrency request serving | Go, Rust, Elixir | Cheap goroutines / async / actors | GC tail at extreme load |
| Glue, tooling, prototyping, scripts | Python | Ecosystem, iteration speed | Never on the inner loop |
| Numerical / data science, research | Python + NumPy/Numba/Polars | Fast iteration, C-backed | Not for production hot loops |
| ML inference / training | Python front + C++/CUDA/Rust backends | Ecosystem + speed | Python alone too slow |
| Frontend web UI | TypeScript + framework | Ecosystem, tooling | Not for server hot path |
| Backend API, CRUD | Go, Node/TS, Rust, Java, C# | Ecosystem and concurrency | GC tails for latency-critical |
| String-heavy parsing, one-shot | Any; prefer current | Rarely hot enough for FFI | — |
| Sandboxed plugin / portable module | Wasm (from Rust/C++/Zig) | Isolation, determinism | wasm↔host overhead |
| Stateful orchestration, ownership-heavy | Rust | Borrow checker prevents aliasing bugs | Verbose for simple pipelines |
| Embedded / no_std / real-time | Rust, C, Zig | No runtime, deterministic | Ecosystem churn |
| Enterprise business logic, JVM teams | Java / Kotlin, C# | Ecosystem, tooling, team | Cold start; GC tails |
| Scripting/automation in-system | Python, Lua, JS | Embeddable, iteration speed | Embedding cost |
| Systems programming, OS-adjacent | Rust, C, Zig | Control, no runtime | Verbose vs higher-level |

## Rule of properties

Language should be chosen by **cycles-per-item** and **latency budget**,
not by name:

- **Compute or memory bandwidth** dominates + strict latency → low-level
  language (Rust / C / C++ / Zig / CUDA).
- **I/O wait** dominates → language matters little; pick the ecosystem
  for the protocol.
- **Branching / allocation** dominates → GC language may win on velocity
  if latency budget allows.
- **Synchronization** dominates → concurrency model decides, not raw
  speed.

## FFI break-even cheat sheet

| Boundary | Cost/call | Break-even work |
|---|---|---|
| C ABI same-process | 10–20 ns | ~200 ns |
| cgo | 100–200 ns | ~2 µs |
| JNI | 50–100 ns | ~1 µs |
| N-API (Node↔C) | 100–200 ns | ~2 µs |
| PyO3 | ~1 µs | ~10 µs |
| ctypes / cffi | 1–5 µs | ~20 µs |
| wasm-bindgen | 1–5 µs | ~20–50 µs |
| Subprocess + pipe | ~1 ms | ~ms |
| gRPC localhost | ~100 µs | ~2 ms |
| Shared memory + ring buffer | 50–100 ns | ~1 µs (stream) |

**5% rule:** if boundary cost > 5% of the call's work, batch calls, use
streaming, or keep the current language.

## When a language is a bad choice — regardless of reputation

- Rust for a 200-line CLI that runs once — toolchain tax > win.
- C++ for a service that spends 90% of time in `wait()` on I/O.
- Go for a per-token streaming pipeline with hard p99 — GC tail.
- Python for an inner loop — the boundary to NumPy already exists;
  rewrite as a NumPy vectorized call, not a whole module.
- Zig / Mojo for a production service in 2025 — ecosystem readiness is
  the blocker; measure before committing.
