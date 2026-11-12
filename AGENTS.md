# Agent instructions

This repository is a **Claude Code skill**. If you are an AI agent
contributing here, read this first.

## What this repo is

- `SKILL.md` — the skill definition. Loaded by Claude Code when the user's
  task matches the `description` / `when_to_use` frontmatter.
- `references/` — deep knowledge, loaded only when `SKILL.md` points to
  them (progressive disclosure).
- `scripts/` — executable helpers, run via Bash, **not** read into context.
- `examples/` — worked end-to-end reports, used as templates.
- `docs/` — human-facing documentation.

## Rules for editing

1. **Never exceed 500 lines in `SKILL.md`.** If a change would grow it
   beyond that, put the detail into `references/` and add a pointer.
2. **Keep `description` under 1024 characters.** It is the trigger that
   decides whether the skill activates.
3. **Preserve the verdict vocabulary** (`SWAP` / `BIND` / `CONSIDER` /
   `KEEP`). Do not invent new verdicts — downstream consumers depend on
   these four.
4. **Preserve the 7-step workflow order** in `SKILL.md`. The output
   contract (7 sections) maps 1:1 to it.
5. **Every claim about a language must cite a property** — compute-bound,
   memory-bound, SIMD, GC, stateful, latency-sensitive — not a reputation.
6. **`scripts/*.sh` must be POSIX-compatible** where possible and
   `shellcheck`-clean.

## Testing

Before proposing changes:

```bash
chmod +x scripts/*.sh tests/*.sh tests/fixtures/*.sh
shellcheck scripts/*.sh tests/*.sh
bash tests/fixtures/create-fixtures.sh
bash tests/test-discover-boundaries.sh
bash tests/test-profile.sh
```

## What not to do

- Do not add a language matrix row without a benchmark command.
- Do not remove the anti-hype pass (Step 6).
- Do not weaken the profiling requirement (Step 2) — "insufficient data" is
  a valid outcome.
- Do not add a "recommended" language. This skill does not recommend
  languages; it evaluates units.
