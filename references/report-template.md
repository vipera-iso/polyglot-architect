# Polyglot review — <project name>

## 1. Component map

| Unit | Current | Responsibility | Boundary | Entry points |
|---|---|---|---|---|

Boundary types: Rust trait / C ABI / HTTP / file format / directory with its
own build target. A unit with no boundary is not a unit.

## 2. Heat map

| Unit | Cold % | Warm % | Hot % | Stateful? | Evidence source |
|---|---|---|---|---|---|

Evidence source is a benchmark, a profiler run, a commit message with numbers,
or "no measurement available". The last one forbids a SWAP verdict for that
row.

## 3. Decision table (post anti-hype)

| # | Unit | Current | Proposed | Property that justifies swap | Verdict |
|---|---|---|---|---|---|

Verdicts: **SWAP**, **CONSIDER**, **KEEP**. "Maybe later" is not a verdict.

## 4. Seam specs

### 4.1 <Unit> — Rust ↔ <lang>
- Mechanism: …
- Ownership: …
- Error model: …
- Marshalling: … ns/call, … bytes/call, … % of call work
- Cancellation: …

## 5. KEEP list

| Unit | Why the current language wins |
|---|---|

## 6. Roadmap

### Phase 1 — <unit> — metric: <p50 latency / RSS / cold-start ms>
### Phase 2 — <unit> — gate: Phase 1 metric improved by ≥X%
### Phase 3 — <unit> — or: stop after Phase 1

## 7. Self-critique

1. Decorative language removed: …
2. If only two languages survived: … and …
3. Biggest polyglot risk: … Mitigation: …
