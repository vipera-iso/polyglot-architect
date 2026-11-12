# Example 01 — Rust workspace (4 crates)

**Repo shape:** Cargo workspace with 4 crates, Rust only.
**Question:** "Should I rewrite part of this in another language?"

## 1. Component map

| Unit | Lang | Responsibility | Boundary | Entry |
|---|---|---|---|---|
| `engine-backend-cpu` | Rust | Matmul, attention kernels | trait `Backend` | `forward()`, `matmul()` |
| `engine-core` | Rust | Model load, graph build | public API | `load()` |
| `engine-runtime` | Rust | KV cache, scheduler | trait `Runtime` | `step()`, `reset()` |
| `engine-server` | Rust | HTTP/gRPC serving | public API | `serve()` |

## 2. Heat map

| Unit | Cold % | Warm % | Hot % | Evidence |
|---|---|---|---|---|
| `engine-backend-cpu` | 0 | 5 | **85** | `cargo flamegraph`, 3200 samples |
| `engine-core` | **40** | 0 | 0 | `perf` on `load()` |
| `engine-runtime` | 0 | 2 | 0 | `heaptrack` |
| `engine-server` | 0 | 8 | 0 | `hyperfine` on 1000 reqs |

## 3. Decision table (post anti-hype)

| # | Unit | Lang | Proposed | Property | Boundary | Verdict | Cost | Revers. |
|---|---|---|---|---|---|---|---|---|
| 1 | `backend-cpu` | Rust | **C/AVX2** | SIMD dense algebra, 85% hot | trait `Backend` | **SWAP** | 2 mo | high |
| 2 | `core` | Rust | — | cold 40%, already fast | — | **KEEP** | — | — |
| 3 | `runtime` | Rust | — | stateful async | — | **KEEP** | — | — |
| 4 | `server` | Rust | — | warm, no hot | — | **KEEP** | — | — |

**Anti-hype:** rejected "Zig tokenizer" (cold, toolchain tax > win) and
"Go server" (Rust async already meets p99; Go adds GC tail).

## 4. Seam spec — `backend-cpu`

```
Boundary:        Rust ↔ C (AVX2 kernels)
Mechanism:       extern "C"
Allocator:       Rust allocates output buffer, C writes in place
Ownership:       borrowed &mut output, Rust-owned
Error model:     return code (0=ok), thread-local message
Threading:       sync both sides, called from tokio spawn_blocking
Cancellation:    cooperative flag checked every K iterations
Marshalling:     ~15 ns/call, 4 KB payload, ~0.03% of 50 µs call
Test oracle:     conformance suite (parity vs current Rust)
Concurrency:     sync C from async Rust → spawn_blocking
```

## 5. KEEP list

| Unit | Why current wins |
|---|---|
| `core` | Cold path; Rust load is already fast |
| `runtime` | Stateful async; borrow checker is the right tool |
| `server` | Rust async meets p99; Go adds GC tail |

## 6. Roadmap

### Phase 1 — `backend-cpu` → C/AVX2
- Metric: p50 latency per forward pass, target −30%
- Shadow mode: flag `backend_c_avx2`, compare against conformance corpus + 1000 prod replays
- Cut-over gate: p50 −30%, p99 no worse, parity 100%
- Rollback: flag off; Rust impl retained in Phase 1

### Phase 2 — none. Stop after Phase 1.

## 7. Self-critique

1. Decorative swaps removed: Zig tokenizer, Go server.
2. If only two languages survived: **Rust + C (AVX2)**.
3. Biggest risk: C kernel drifting from Rust trait. Mitigation:
   conformance suite in CI on every trait change.
