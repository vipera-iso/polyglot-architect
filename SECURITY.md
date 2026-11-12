# Security policy

## Reporting

Report security issues to `<your-email>` or open a private advisory on
GitHub. Do not open public issues for anything that could be exploited.

## Scope

`polyglot-architect` is a **Claude Code skill** — a set of Markdown
instructions and two shell scripts. It does not run as a service, does not
hold credentials, and does not transmit data anywhere.

Known scope boundaries:

- The skill **reads** the user's repository (source code, build files).
- The skill **runs** profilers that the user has installed (`cargo
  flamegraph`, `py-spy`, `perf`, etc.). These tools have their own security
  posture.
- The skill **does not** execute the user's code — it invokes profilers
  that do, and the user is responsible for trusting those invocations.

## Threat model

| Threat | Mitigation |
|---|---|
| Untrusted repo contains malicious build script triggered by profiler | Skill does not build; only profiles already-built binaries. User runs `cargo build` / `npm run build` themselves. |
| Profiler installed from untrusted source | Out of scope — the user's own tool installation. |
| Skill script executes arbitrary user input | `discover-boundaries.sh` and `profile.sh` accept a directory path only. No `eval`, no `sh -c` on user strings. |
| Secrets in profiler output leaked into report | Reports are generated in the working directory, not transmitted. Redaction is the user's responsibility when publishing. |

## Not in scope

- Vulnerabilities in Claude Code itself — report to Anthropic.
- Vulnerabilities in profilers — report to their maintainers.
- Vulnerabilities in the user's project — this skill only reviews architecture.
