# Worked example — three different projects, same skill

## Example A — Rust inference engine (Cargo workspace)

### Decision table (post anti-hype)

| # | Unit | Lang | Proposed | Property | Boundary | Verdict | Cost | Revers. |
|---|---|---|---|---|---|---|---|---|
| 1 | backend-cpu | Rust | C/AVX2 | 85% hot, SIMD | trait `Backend` | **SWAP** | 2 mo | high |
| 2 | core | Rust | — | cold 40% | public API | **KEEP** | — | — |
| 3 | server | Rust | Go | warm, no hot | public API | **KEEP** | — | — |
| 4 | runtime | Rust | — | stateful async | trait `Runtime` | **KEEP** | — | — |

**Anti-hype:** removed "Zig tokenizer" (cold, tax > win) and "Go server"
(Rust async meets p99; Go adds GC tail). **Surviving: Rust + C (AVX2).**

**Roadmap Phase 1:** `backend-cpu` → C/AVX2 behind `backend_c_avx2` flag,
shadow mode on conformance suite, cut over when p50 improves ≥ 30%.
**Phase 2: none.**

---

## Example B — Node/TypeScript API monolith (single package)

### Heat map
| Unit | Cold % | Warm % | Hot % | Evidence | Profiler |
|---|---|---|---|---|---|
| `api` | 0 | 20 | 0 | 5k req bench | clinic |
| `pipeline` | 0 | 40 | 55 | leaf-heavy flame | clinic |
| `db` | 0 | 5 | 0 | 5k req bench | clinic |
| `image-codec` | 0 | 35 | 45 | flat flame | clinic |

### Decision table (post anti-hype)

| # | Unit | Lang | Proposed | Property | Boundary | Verdict | Cost | Revers. |
|---|---|---|---|---|---|---|---|---|
| 1 | `pipeline` | TS | Bind sharp | memory-bound C | export | **BIND** | 1 mo | high |
| 2 | `image-codec` | TS | Bind sharp | codec solved | export | **BIND** | 0.5 mo | high |
| 3 | `api` | TS | — | warm | — | **KEEP** | — | — |
| 4 | `db` | TS | — | warm | — | **KEEP** | — | — |

**Anti-hype:** did **not** propose rewriting `pipeline` in Rust. Binding
to `sharp` (wraps libvips in C) wins at 10× less cost.
**Surviving: TypeScript + C (via sharp).**

---

## Example C — Go microservice mesh + Python ML sidecar

### Heat map
| Unit | Cold % | Warm % | Hot % | Evidence | Profiler |
|---|---|---|---|---|---|
| `gateway` | 0 | 30 | 0 | pprof 1k req/s | pprof |
| `auth` | 0 | 10 | 0 | pprof | pprof |
| `feature-store` | 0 | 25 | 0 | pprof | pprof |
| `ml-sidecar` | 5 | 20 | 45 | py-spy + perf | py-spy |

### Decision table (post anti-hype)

| # | Unit | Lang | Proposed | Property | Boundary | Verdict | Cost | Revers. |
|---|---|---|---|---|---|---|---|---|
| 1 | `ml-sidecar` inference | Python | Bind ONNX Runtime | matmul in model | py-spy leaf | **BIND** | 1 mo | high |
| 2 | `ml-sidecar` preprocess | Python | — | small | — | **KEEP** | — | — |
| 3 | `gateway` | Go | — | warm | — | **KEEP** | — | — |
| 4 | `auth` | Go | — | warm | — | **KEEP** | — | — |
| 5 | `feature-store` | Go | — | warm | — | **KEEP** | — | — |

**Anti-hype:** did **not** propose rewriting Python service in Rust. Hot
path is model inference — already C++ via numpy/ONNX. Binding ONNX Runtime
solves the actual bottleneck.
**Surviving: unchanged (Go + Python).**

---

## Pattern across examples

1. Detect boundaries — crates, directories, or services.
2. Profile — always with a real tool, never from code reading.
3. Match property to language — not to name.
4. Prefer BIND over SWAP when a mature library exists.
5. KEEP is common — most units were KEEP in all three examples.
6. Surviving languages ≤ 2 — a third needs a metric current two can't
   reach.
7. Shadow mode is mandatory in Phase 1.
