# Example 04 — Mixed monorepo (Rust + Node + Python + Bazel)

**Repo shape:** Bazel monorepo with Rust core, Node tooling, Python data
scripts, and one C++ native addon.
**Question:** "Add a fourth language for the new feature?"

## 1. Component map

| Unit | Lang | Responsibility | Boundary |
|---|---|---|---|
| `core/` | Rust | Core engine | `cc_library` (public) |
| `tools/` | Node | CLI tooling | `node_library` |
| `scripts/` | Python | Data prep | `py_library` |
| `native/codec/` | C++ | Codec addon | `cc_library` |
| `web/` | TypeScript | Dashboard | `ts_library` |

## 2. Heat map

| Unit | Cold % | Warm % | Hot % | Evidence |
|---|---|---|---|---|
| `core/` | 10 | 30 | **40** | perf on Bazel-built binary |
| `native/codec/` | 0 | 5 | 0 | perf |
| `tools/` | 5 | 5 | 0 | manual |
| `scripts/` | 15 | 0 | 0 | hyperfine |
| `web/` | 0 | 5 | 0 | clinic |

## 3. Decision table (anti-hype result)

| # | Unit | Lang | Proposed | Verdict |
|---|---|---|---|---|
| 1 | `core/` | Rust | — | **KEEP** (Rust already wins) |
| 2 | `native/codec/` | C++ | Rust | **CONSIDER** (measure first) |
| 3 | *new feature* | — | Zig | **REJECT** |
| 4 | *new feature* | — | Rust (in `core/`) | **SWAP-in-place** |

**Anti-hype — the key decision:**

The user proposed a **fourth language (Zig)** for a new feature. Anti-hype
rejected it:

- The feature's property is compute + shared state → Rust already covers it.
- Zig would be the **fourth** language. Toolchain tax (Bazel toolchain,
  CI image, debugger, formatter, linter) ≈ 2–3 dev-months *before* any
  code is written.
- No metric shows Zig beating Rust for this workload.
- The feature can live inside `core/` behind the existing `cc_library`
  boundary — zero new toolchain.

**Result:** implement the feature in Rust, inside `core/`. Language count
stays at 4 (Rust, Node, Python, C++), which is already at the practical
limit.

## 4. Seam spec — `native/codec/` → Rust (CONSIDER, not approved)

```
Boundary:        C++ ↔ Rust via cc_library
Mechanism:       extern "C" (Bazel cc_library)
Allocator:       must be documented before Phase 1
Error model:     return code
Threading:       sync
Cancellation:    n/a (< 1 ms calls)
Marshalling:     ~20 ns/call, ~1 KB payload
Test oracle:     Bazel parity tests + conformance
Blocking:        needs benchmark showing C++ codec is hot before SWAP
```

## 5. KEEP list

| Unit | Why |
|---|---|
| `core/` | Rust already optimal |
| `tools/` | Node warm, not hot |
| `scripts/` | Python one-shot, cold |
| `web/` | TS warm, not hot |
| `native/codec/` | Not measured as hot; CONSIDER not SWAP |

## 6. Roadmap

### Phase 1 — implement new feature inside `core/` (Rust)
- Metric: feature latency p50, target < 20 ms
- Shadow: n/a — new code, no old impl to compare
- Cut-over: feature behind flag `feature_x_rust`; ship when p50 < 20 ms

### Phase 2 — measure `native/codec/` before deciding
- Only proceed if `perf` shows codec > 5% of total time.

### Phase 3 — do NOT add Zig.

## 7. Self-critique

1. Decorative swap removed: **Zig new feature** — would make the
   architecture worse by paying 2–3 dev-months of toolchain tax for no
   metric gain.
2. If limited to two strongest languages: **Rust + Node** (Python and C++
   are legacy/support).
3. Biggest polyglot risk here: **Bazel toolchain divergence**. Already 4
   languages at practical limit. Mitigation: freeze language count at 4;
   new features must go into an existing language or be rejected.
