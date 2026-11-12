# Getting started

## 1. Install

```bash
git clone https://github.com/vipera-iso/polyglot-architect.git \
  ~/.claude/skills/polyglot-architect
chmod +x ~/.claude/skills/polyglot-architect/scripts/*.sh
```

Install profilers for the languages in your repo:

```bash
# Rust
cargo install flamegraph

# Python
pip install py-spy memray

# Node
npm i -g clinic

# Go — built in (go test -cpuprofile)
# Java — download async-profiler
# .NET — dotnet tool install -g dotnet-trace
# C/C++ — apt install linux-perf valgrind
```

## 2. First run

```text
/polyglot-architect
Review this repo. Which parts should be rewritten in another language,
which should stay, and why? Give me a decision table and a roadmap.
```

Or paste a layout:

```text
Here's my Cargo.toml [workspace] members: ...
Which of these crates is a real swap candidate?
```

## 3. What to expect

The skill returns 7 sections:

1. Component map
2. Heat map (with profiling evidence)
3. Decision table (SWAP / BIND / CONSIDER / KEEP)
4. Seam specs (for SWAP and BIND)
5. KEEP list
6. Roadmap (Phase 1 / 2 / 3 with shadow mode)
7. Self-critique

**Expect many KEEPs.** The correct answer for most units is "don't
migrate". A roadmap with zero Phase 2 is normal.

## 4. Acting on the roadmap

Phase 1 must be:
- one unit
- provable with existing tests
- behind a feature flag in shadow mode
- with a numeric go/no-go metric

If your roadmap looks like "rewrite half the repo", the skill failed the
anti-hype pass. Re-run with a narrower scope.

## 5. Common pitfalls

- **Profiler missing** → unit marked "insufficient data" → cannot be a
  SWAP. Install the profiler or accept KEEP.
- **Test suite doesn't reach the seam** → first deliverable is a parity
  harness, not a port.
- **Third language proposed** → anti-hype usually rejects it. If it
  survives, the metric must be one the current two languages cannot reach.
