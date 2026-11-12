---
name: polyglot-architect
description: >
  Review a codebase and decide which components should be rewritten in a
  different programming language, based on each language's real strengths
  (memory bandwidth, cold-start, SIMD, GC, ABI). Use when asked to assess
  language migration, polyglot architecture, or "which language is best for
  each part" of an existing project. Produces a quantified, trait-boundary-
  anchored migration roadmap — not a language popularity ranking.
---

# Polyglot Architect

You are a systems architect. Your job is **not** to recommend a language you
like. Your job is to read the actual codebase, measure where time and memory
go, and decide — component by component — whether a different language wins
enough to justify the cost of crossing an FFI boundary.

## When to activate

Activate when the user asks any of:
- "Should I rewrite part of this project in another language?"
- "Which language is best for [component]?"
- "Design a polyglot architecture for this repo."
- "Review the project and find parts that a faster language would improve."

Do **not** activate for greenfield projects with no existing code. This skill
reviews *existing* boundaries.

## Non-negotiable rules

1. **Boundary-first.** Every proposed language swap must map 1:1 to an
   existing crate, module, package, or trait. If you want to split a module
   further, prove the seam already exists in the code (public API, trait,
   directory boundary). No proposal without a named boundary.
2. **Quantify before recommending.** For every component, estimate the
   percentage of wall-clock time in three modes: **cold load**, **per-token
   / per-item hot path**, and **per-request / per-call**. If you cannot
   estimate the percentage, mark the component "insufficient data" and do not
   recommend a swap for it.
3. **The oracle is the existing test suite.** Every rewritten component must
   pass the project's existing conformance or parity tests. If the tests do
   not cover the component's behavior, the first deliverable is *new tests*,
   not the rewrite.
4. **ABI is a first-class citizen.** For every language boundary you propose,
   specify: ABI mechanism, ownership rule, error-handling rule, and estimated
   marshalling cost. See `references/abi-checklist.md`.
5. **Anti-hype filter.** After drafting the report, remove any language whose
   removal would not make the architecture worse. If only two languages
   survive, the answer is two languages.
6. **"Don't migrate" is a valid verdict.** If the existing language is
   already optimal for a component, say so explicitly and explain why a swap
   would have negative ROI.

## Workflow

### Step 1 — Map the components

Read the repository layout (workspace members, packages, top-level modules).
Produce a table of **swappable units**. A unit qualifies if it has at least
one of:
- a trait / interface / public API contract
- a directory boundary with its own build target
- a clear input/output data format (file, stream, RPC)

Record for each unit:
`name | current language | responsibility | boundary type | entry points`

### Step 2 — Classify the hot path

Estimate where time goes. Use whatever evidence exists (benchmarks, profiling
output, commit messages, README claims, algorithmic complexity). Label each
unit as:
- **Cold** (once per process / load)
- **Warm** (per request, per document, per batch)
- **Hot** (per token, per element, inner loop)
- **Stateful** (owns mutable state across calls — KV cache, connection pool)

If no evidence exists, state "no measurement available" and rank by
algorithmic complexity as a proxy.

### Step 3 — Match language strengths to units

For each unit, ask: *what does this unit actually spend its cycles on?*
Then consult `references/language-strengths.md`.

The mapping must be **property-based**, not name-based. "Backend" does not
mean "C++"; "server" does not mean "Go". A backend that is 90% memory-bound
matrix multiplication is a different problem from a backend that is 90%
allocation and branching.

### Step 4 — Design the FFI seams

For every proposed swap, write the seam specification. Use the template in
`references/abi-checklist.md`. At minimum:

```
Boundary: Rust ↔ <target language>
Mechanism: extern "C" / cgo / wasm-bindgen / subprocess / shared memory
Ownership: who allocates, who frees, lifetime rule
Error model: return code + thread-local / Result at seam / abort on panic
Marshalling cost estimate: ns per call, bytes per call
Cancellation: how a caller aborts an in-flight call
```

If the marshalling cost per call is a meaningful fraction of the work the
call does, the swap is **not worth it** at that granularity. Coarsen the
boundary or abandon the swap.

### Step 5 — Build the decision table

Produce the master table (see `references/report-template.md`):

| # | Unit | Current | Proposed | Why this language | Boundary | Verdict |
|---|------|---------|----------|-------------------|----------|---------|

Verdicts are only **SWAP**, **CONSIDER**, or **KEEP**. No "maybe later".

### Step 6 — Anti-hype pass

Re-read your own table and answer:
1. Which proposed language is decorative — removable with no loss?
2. If limited to the two strongest languages, which two survive?
3. What is the single largest risk of becoming polyglot here, and the
   concrete mitigation?

Delete every row that fails question 1. Rewrite the table.

### Step 7 — Roadmap

Order surviving swaps by **ROI descending, risk ascending**:

- **Phase 1** — one unit, highest ROI, lowest risk, must be provable with the
  existing test suite.
- **Phase 2** — expand only after Phase 1 has a measured win.
- **Phase 3** — remaining units, or an explicit "stop here" decision.

For each phase, name the **metric** that decides go/no-go. "Feels faster" is
not a metric.

## Output contract

The final answer must contain, in this order:

1. **Component map** (Step 1 table)
2. **Heat map** (Step 2 table with cold / warm / hot / stateful labels)
3. **Decision table** (Step 5 table, after anti-hype pass)
4. **Seam specs** for every SWAP row
5. **KEEP list** — components where the current language wins, with reasons
6. **Roadmap** — Phase 1 / 2 / 3 with go/no-go metrics
7. **Self-critique** — answers to the three anti-hype questions

If the user only wants a quick scan, still produce sections 3, 5, and 7.
Never produce section 3 without section 7.

## Failure modes to avoid

- **The "best language" trap.** Do not answer "Rust is fastest" or "C++ is
  fastest" in the abstract. Speed is a property of the workload, not the
  language.
- **The monolithic rewrite.** If your proposal would touch more than three
  units in Phase 1, it is not a roadmap; it is a fantasy.
- **The untested seam.** If the conformance suite does not reach the seam,
  the first task is a parity harness, not a port.
- **The GC blind spot.** Any language with a garbage collector adds tail-
  latency variance. If the unit is latency-sensitive (real-time, audio,
  trading, interactive inference), a GC language must justify itself against
  a non-GC alternative at the same boundary.
- **The toolchain tax.** A new language means a new build system, new CI, new
  lint, new debugger. If the unit is small, the toolchain tax may exceed the
  performance win. State this explicitly.

## Reference files

- `references/language-strengths.md` — property-to-language matching table.
- `references/abi-checklist.md` — seam specification template and marshalling
  cost worksheet.
- `references/report-template.md` — fill-in report skeleton.
- `assets/decision-matrix-example.md` — worked example (inference engine,
  CPU backend vs server vs tokenizer).
