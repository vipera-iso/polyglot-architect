# Polyglot review — <project name>

## 0. Project detection
- Type: <Cargo workspace / npm monorepo / Go modules / Maven multi-module /
  .NET solution / Bazel / microservices / monolith / polyglot>
- Languages present: <list>
- Build system(s): <list>
- Test suites: <list> (candidate oracles)

## 1. Component map
| Unit | Language | Responsibility | Boundary type | Entry points | LOC |

## 2. Heat map
| Unit | Cold % | Warm % | Hot % | Stateful? | Evidence source | Profiler |

Evidence must name a real artifact. "no measurement" allowed but cannot be
a SWAP row.

## 3. Decision table (post anti-hype)
| # | Unit | Lang | Proposed | Property justifying swap | Boundary | Verdict | Cost (dev-mo) | Reversibility |

Verdict ∈ {SWAP, BIND, CONSIDER, KEEP}. Cost and reversibility mandatory
for SWAP and BIND. CONSIDER must name the exact measurement needed.

## 4. Seam specs
### 4.1 <Unit> — <langA> ↔ <langB>
- Mechanism: …
- Allocator: …
- Ownership: …
- Error model: …
- Threading: …
- Cancellation: …
- Marshalling: … ns/call, … bytes/call, … % of call work
- Test oracle: …
- Concurrency risk: <from concurrency-models.md>

(Repeat for each SWAP and BIND row.)

## 5. KEEP list
| Unit | Why current language wins | Would a swap ever be justified? |

## 6. Roadmap
### Phase 1 — <unit> — verdict: SWAP
- Metric: <p50 / p99 / RSS / cold-start ms / throughput>
- Shadow-mode: feature flag `<flag-name>`, run both impls in parallel,
  compare against test corpus + `<N>` production replays.
- Cut-over gate: Phase 1 metric improves ≥ <X>% and no regression in
  <secondary metric>, for ≥ N consecutive days.
- Rollback: flip flag off. No code removed in Phase 1.

### Phase 2 — <unit>
- Gate: Phase 1 metric improved by ≥ X% in production for ≥ N days.

### Phase 3 — <unit> — or: stop after Phase 1.

## 7. Self-critique
1. Decorative swap removed: <unit> — because <reason>.
2. If limited to two strongest languages: <langA> and <langB>.
3. Biggest polyglot risk: <risk>. Mitigation: <concrete action>.
