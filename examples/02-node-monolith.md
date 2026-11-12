# Example 02 — Node/TypeScript API monolith (single package)

**Repo shape:** single npm package, ~7.5k LOC, TypeScript only.
**Question:** "Which parts should be rewritten?"

## 2. Heat map

| Unit | Cold % | Warm % | Hot % | Evidence |
|---|---|---|---|---|
| `src/api/` | 0 | 20 | 0 | clinic doctor, 5k req bench |
| `src/pipeline/` | 0 | 40 | **55** | flamegraph leaf-heavy |
| `src/db/` | 0 | 5 | 0 | 5k req bench |
| `src/image-codec/` | 0 | 35 | **45** | flat flamegraph |

## 3. Decision table

| # | Unit | Lang | Proposed | Property | Verdict | Cost |
|---|---|---|---|---|---|---|
| 1 | `pipeline` | TS | **Bind `sharp`** | resize = memory-bound C | **BIND** | 1 mo |
| 2 | `image-codec` | TS | **Bind `sharp`** | codec already solved | **BIND** | 0.5 mo |
| 3 | `api` | TS | — | warm | **KEEP** | — |
| 4 | `db` | TS | — | warm | **KEEP** | — |

**Anti-hype:** did **not** propose rewriting `pipeline` in Rust. `sharp`
wraps libvips (C) — 10× cheaper than a Rust port with the same result.

## 4. Seam spec — `pipeline` → sharp

```
Boundary:        TS ↔ C (libvips via sharp)
Mechanism:       N-API (sharp uses node-addon-api)
Allocator:       sharp manages internally; returns Buffer
Ownership:       Buffer copied at boundary
Error model:     Promise rejection with typed error
Threading:       libuv thread pool (sharp offloads)
Cancellation:    Promise is not abortable — pipeline is short (< 100 ms)
Marshalling:     ~200 ns/call + image bytes copy
Test oracle:     existing snapshot tests
```

## 6. Roadmap

### Phase 1 — replace `pipeline` + `image-codec` with `sharp`
- Flag: `USE_SHARP`
- Metric: p95 latency on resize, target −50%
- Shadow: both paths run, compare output hashes and latency
- Cut-over: p95 −50%, 0 hash mismatches, 3 days stable

### Phase 2 — none.
