# Contributing

Thanks for helping improve **polyglot-architect**.

## What to contribute

Highest-value contributions:

1. **New worked example** — run the skill on a real repo, publish the report
   under `examples/`. Include the repo layout, profiling command, and the
   final decision table. Redact proprietary names.
2. **Language matrix entries** — measured FFI break-even numbers for a
   boundary or tool we don't cover. Include the benchmark command and
   environment.
3. **Profiler additions** — a language whose profiler we don't list in
   `references/profiling-tools.md`.
4. **Bug reports** — where the skill made a wrong recommendation, and what
   evidence would have caught it.

## Local checks

Before opening a PR:

```bash
chmod +x scripts/*.sh tests/*.sh tests/fixtures/*.sh
shellcheck scripts/*.sh tests/*.sh
bash tests/fixtures/create-fixtures.sh
bash tests/test-discover-boundaries.sh
bash tests/test-profile.sh
wc -l SKILL.md    # must stay under 500
```

CI runs the same checks.

## Style

- **SKILL.md body** stays under 500 lines. Move detail into `references/`.
- **Frontmatter** must have `name` and `description`. Description stays
  under 1024 characters, contains trigger phrases.
- **Prescriptive at seams, flexible elsewhere.** Explain *why*, not just
  *must*.
- **No language-by-reputation advice.** Every claim about a language must
  name the property of the workload that makes it win.

## Reporting a wrong recommendation

If the skill recommended a swap that turned out to be negative-ROI:

1. Describe the repo shape (language, layout).
2. Paste the decision table it produced.
3. State the metric you measured after the swap.
4. Suggest which rule or reference would have caught it.

This is the most valuable bug report — it directly improves the skill's
decision rules.
