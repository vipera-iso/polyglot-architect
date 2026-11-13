<div align="center">

# Polyglot Architect

**Review any codebase. Decide component by component which language wins. Ship a migration roadmap — not a language popularity ranking.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-blue)](https://docs.claude.com/en/docs/claude-code/skills)
[![AgentSkills](https://img.shields.io/badge/agentskills.io-compatible-green)](https://agentskills.io)

English · [Tiếng Việt](docs/multi-language/README.vi.md) · [简体中文](docs/multi-language/README.zh.md)

[Quick start](#quick-start) · [How it works](#how-it-works) · [Workflow](#workflow) · [Examples](examples/) · [FAQ](docs/faq.md)

</div>

---

## What it is

A **Claude Code skill** that turns your AI agent into a systems architect.
Ask it to review a repo, and it will:

1. **Read** the actual codebase — detect project type, list every unit that has a real boundary.
2. **Profile** the project with the right tool per language (`cargo flamegraph`, `py-spy`, `pprof`, `perf`, `async-profiler`, `dotnet-trace`).
3. **Match** each hot unit's *properties* (compute-bound, memory-bound, SIMD, GC, stateful) to a language — never by reputation.
4. **Decide** per unit: **SWAP**, **BIND**, **CONSIDER**, or **KEEP**.
5. **Design** the FFI seam: mechanism, ownership, error model, threading, cancellation, marshalling cost.
6. **Roadmap** with shadow-mode + feature flag + measurable go/no-go metric per phase.
7. **Self-critique** — remove decorative swaps, keep only languages that pay for themselves.

The answer is quantified. **"Don't migrate" is a valid and common verdict.**

## Why not just ask "what language should I use?"

Because "what language is fastest" is the wrong question. Speed is a property of the **workload**, not the language. This skill forces the workflow that experienced systems engineers actually use:

| Naive advice | This skill |
|---|---|
| "Rewrite it in Rust" | "Which unit? Is it hot? By how much? What does profiling say?" |
| "Go is great for servers" | "Is this unit per-request or per-token? What's the latency budget? GC tail?" |
| "Use C++ for speed" | "Is the cost of crossing the FFI boundary > 5% of the call's work?" |
| "Add a third language" | "Can the current two languages reach the target metric? Show the number." |

## Quick start

```bash
git clone https://github.com/vipera-iso/polyglot-architect.git \
  ~/.claude/skills/polyglot-architect
chmod +x ~/.claude/skills/polyglot-architect/scripts/*.sh
```

Then in Claude Code:

```text
/polyglot-architect

# or just ask:
Review my repo and tell me which parts should be rewritten in
another language, which should stay, and why.
```

## How it works

```
 ┌─────────────────────────────────────────────────────────────┐
 │  Your agent (Claude Code / Codex / Cursor / any MCP client) │
 └────────────────────────────┬────────────────────────────────┘
                              │ asks
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │                  Polyglot Architect skill                   │
 │  Step 0: verify every number you were handed                │
 │  Step 1: detect project type → map units                    │
 │  Step 2: profile → classify cold / warm / hot / stateful    │
 │  Step 3: match language by property, not name               │
 │  Step 4: design FFI seam + marshalling cost                 │
 │  Step 5: decision table (SWAP / BIND / CONSIDER / KEEP)     │
 │  Step 6: anti-hype pass → delete decorative swaps           │
 │  Step 7: roadmap with shadow mode + go/no-go metric         │
 └────────────────────────────┬────────────────────────────────┘
                              │ reads
                              ▼
 ┌─────────────────────────────────────────────────────────────┐
 │  references/   layouts, language matrix, ABI, measurement   │
 │  scripts/      discover-boundaries.sh, profile.sh           │
 │  examples/     worked decision-matrix reports               │
 └─────────────────────────────────────────────────────────────┘
```

Full details: [docs/workflow.md](docs/workflow.md).

## Supported projects

| Project type | Detection marker |
|---|---|
| Rust workspace | `Cargo.toml` `[workspace]` |
| Node / pnpm / yarn monorepo | `package.json` `workspaces`, `pnpm-workspace.yaml` |
| Go modules | `go.mod` |
| Python (uv / poetry / setuptools) | `pyproject.toml`, `setup.py` |
| Maven / Gradle multi-module | `pom.xml`, `settings.gradle` |
| .NET solution | `*.sln`, `*.csproj` |
| C / C++ | `CMakeLists.txt`, `Makefile` |
| Bazel | `WORKSPACE`, `BUILD` |
| Microservices | per-service boundaries |
| Polyglot (already multi-language) | each language block |
| Generic monolith | top-level directory boundaries |

See [references/project-layouts.md](references/project-layouts.md).

## Verdicts

| Verdict | Meaning | Typical cost |
|---|---|---|
| **SWAP** | Replace implementation with another language behind the existing boundary | 1–6 dev-months |
| **BIND** | Keep current code, call a mature library in another language | 0.5–1 dev-month |
| **CONSIDER** | Plausible but under-evidenced; must name the exact measurement needed | — |
| **KEEP** | Current language wins; swap is negative-ROI | — |

**BIND is almost always cheaper than SWAP** when the target work is already solved by a library (`sharp`, `tokenizers`, `onnxruntime`, `libjpeg`).

## Examples

Worked end-to-end reports:

- [Rust workspace](examples/01-rust-workspace.md) — 4 crates, one SWAP.
- [Node/TypeScript monolith](examples/02-node-monolith.md) — two BINDs, zero rewrites.
- [Go mesh + Python ML sidecar](examples/03-go-python-mesh.md) — no language change; bind ONNX.
- [Mixed monorepo](examples/04-monorepo-polyglot.md) — fourth language rejected by anti-hype.

## FAQ

**Do I need to change languages?** No — most repos get zero SWAPs. KEEP is the most common verdict.

**Does it require profiling tools?** Yes — no swap without measurement. Missing profilers → unit marked "insufficient data".

**Does it work for microservices?** Yes — each service is a unit, and the RPC protocol is the seam.

**What if my project has no clear boundaries?** The skill proposes "create the seam first" in the current language.

See [docs/faq.md](docs/faq.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bug reports, new examples, new language matrix entries are welcome.

## License

MIT — see [LICENSE](LICENSE).

## Disclaimer

This skill produces **architecture recommendations**, not legal, security, or performance guarantees. Validate any proposal against your own workload, team, and risk tolerance.
