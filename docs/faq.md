# FAQ

**Is this just "which language is fastest"?**
No. It answers "for *this specific unit*, is a different language worth
the FFI cost, the rewrite cost, and the toolchain tax?" Most answers are
KEEP.

**Does it require me to change languages?**
No. Most reviews produce zero SWAPs. BIND (call an existing library) is
often the right answer, and KEEP is the most common.

**What if I don't have profilers installed?**
The skill marks the unit "insufficient data" and refuses to recommend a
swap for it. It will tell you which profiler to install.

**Can it review a monorepo?**
Yes — npm/pnpm workspaces, Nx, Turborepo, Bazel, Cargo workspace, and
generic monorepos are all detected.

**Can it review microservices?**
Yes — each service is a unit, and the RPC protocol is the seam.

**My repo is already polyglot (3 languages). Will it add a fourth?**
Almost never. The anti-hype pass (Step 6) requires a metric the current
languages cannot reach. A fourth language usually fails this test.

**Does it run my code?**
No. It runs profilers on binaries that *you* build. See [SECURITY.md](../SECURITY.md).

**What's the difference between SWAP and BIND?**
- SWAP = rewrite the implementation in another language.
- BIND = keep the current code, but call a mature library in another
  language (e.g. `sharp`, `onnxruntime`, `tokenizers`).

BIND is typically 5–10× cheaper than SWAP when a library exists.

**What if the recommendation is wrong?**
That's the most valuable bug report — see [CONTRIBUTING.md](../CONTRIBUTING.md).

**Does it work outside Claude Code?**
The `SKILL.md` format is compatible with any agent that reads skills
(Claude Code, Codex, Cursor, Gemini CLI). The scripts are plain Bash.
