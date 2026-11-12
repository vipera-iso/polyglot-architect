# polyglot-architect

An agent skill that reviews an existing codebase and decides, component by
component, whether another programming language would actually win — then
proves it with numbers, or says **don't migrate**.

It exists because "rewrite it in Rust/Go/Zig/C++" is usually a guess dressed as
an architecture. The skill forces the guess into a shape that can fail:

- every proposed swap must map to a boundary that already exists (crate,
  module, trait, RPC) — no invented seams;
- every component is quantified as cold / per-request / per-token share of wall
  clock, or marked "insufficient data" and left alone;
- the existing conformance suite is the oracle; if it does not cover the seam,
  the first deliverable is tests, not a port;
- the language boundary is specified like an API: ABI, ownership, error model,
  marshalling cost, cancellation;
- a mandatory anti-hype pass deletes any language whose removal loses nothing.

The default verdict is **keep**. A swap has to earn its toolchain tax.

## Install

Copy the directory into your agent's skills folder:

```sh
git clone https://github.com/vipera-iso/polyglot-architect
cp -r polyglot-architect ~/.agents/skills/polyglot-architect
# Claude Code reads ~/.claude/skills; a symlink keeps one copy
ln -s ~/.agents/skills/polyglot-architect ~/.claude/skills/polyglot-architect
```

Or, with the `skills` CLI:

```sh
npx skills add vipera-iso/polyglot-architect --skill polyglot-architect --yes
```

## Use

Ask a question that matches the description, or invoke it by name:

- "Design a polyglot architecture for this repo."
- "Which parts of this project should be rewritten in another language?"
- "Is Zig worth it for our kernels?"

The skill answers with a component map, a heat map, a decision table, seam
specs, a KEEP list, a phased roadmap with go/no-go metrics, and a
self-critique. It is allowed to conclude that the current single language is
already right.

## What it is not

- Not a language ranking. Speed is a property of the workload, not a language.
- Not a greenfield design tool. It reviews boundaries that already exist.
- Not a rewrite planner for whole repos. Phase 1 is one unit, or the plan is
  rejected as fantasy.

## Files

```
SKILL.md                            the skill body (7-step workflow + output
                                    contract)
scripts/discover-boundaries.sh      detect project type, list candidate units
scripts/profile.sh                  language-agnostic profiler dispatcher
references/project-layouts.md       where seams live in any project type
references/language-strengths.md    property-to-language matching, and what a
                                    language cannot fix (bandwidth, layout, cache)
references/profiling-tools.md       profiler lookup per language, and how to
                                    read a flamegraph
references/concurrency-models.md    cross-runtime risk matrix, cancellation
references/abi-checklist.md         seam template + marshalling worksheet
references/report-template.md       fill-in report skeleton
assets/decision-matrix-example.md   three worked examples: Rust engine, Node
                                    monolith, Go mesh + Python sidecar
```

The worked examples are deliberately mostly KEEP rows: they show the filter
doing its job — in all three, the swaps that survive are bindings to mature
libraries that already exist, and no example ends with more than two
languages.

The two scripts are optional helpers — the skill works without them.
`profile.sh` delegates to per-language profilers that are installed
separately when you want real measurements (`cargo install flamegraph`,
`pip install py-spy memray`, `npm i -g clinic`, or `perf` / `valgrind` for
C and C++).

## License

MIT — see `LICENSE-MIT`.
