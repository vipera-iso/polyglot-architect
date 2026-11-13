# Changelog

All notable changes are documented here. This project follows
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `references/measurement-hygiene.md` — provenance, denominators, sample size,
  spread, and how to measure a machine's ceiling (STREAM + read-only kernel),
  with a worked example of four wrong numbers caught before they reached a
  report.

### Changed
- **Step 0 — audit the numbers you were handed.** Incoming baselines are
  claims until re-run: check denominator, sample size, attribution, and
  plausibility against a measured ceiling.
- **Step 2b — split a unit that owns >50% of the clock.** Crates are too
  coarse for hot-path work; time per shape and call site, and report
  `calls/pass`, `ms/call`, and achieved GB/s.
- **KEEP is not a stopping point.** Every KEEP row now carries the next
  in-language lever and the measurement that would reopen the question.
- **New verdict `CONSIDER-GOAL`** for a binding that defeats the project's
  stated purpose — an owner decision, never an agent recommendation.
- **Claim audit in Step 6** for proposals that arrive with third-party
  benchmark speedups: same workload, same machine class, plausible against
  the measured ceiling, and whether the language changes anything at the
  instruction level.
- Three new failure modes: the granularity trap, the imported number, the
  productivity wolf.

## [0.1.0] — 2026-11-12

### Added
- Initial skill: `polyglot-architect` with 7-step workflow.
- `references/project-layouts.md` — 10 project types supported.
- `references/language-strengths.md` — property → language matrix, FFI
  break-even table.
- `references/profiling-tools.md` — 9 languages + universal tools.
- `references/abi-checklist.md` — 9 FFI mechanisms.
- `references/concurrency-models.md` — 12 caller↔callee pairs.
- `references/report-template.md` — 7-section output skeleton.
- `scripts/discover-boundaries.sh` — auto-detect project type.
- `scripts/profile.sh` — language-agnostic profiler dispatcher.
- `examples/` — 4 worked reports (Rust, Node, Go, mixed monorepo).
- `.claude-plugin/` — marketplace-ready plugin metadata.
- CI: validate skill, markdown lint.
- Test suite with 3 fixture repos.
