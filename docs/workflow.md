# Workflow

The 7-step workflow is defined in `SKILL.md`. This document explains
*why* each step exists and what failure mode it prevents.

## Step 1 — Map units
**Prevents:** proposing a swap with no boundary (untestable, unbounded risk).
**Rule:** a unit must have an existing trait, build target, or data
interface. If not, the deliverable is "create the seam first", not a port.

## Step 2 — Profile
**Prevents:** guessing from code reading.
**Rule:** no swap without measurement. "Insufficient data" is a valid
label and blocks the swap.

## Step 3 — Match by property
**Prevents:** "Rust is fast" style advice.
**Rule:** the language is chosen by what the unit *spends cycles on*,
not by its name or its domain label.

## Step 4 — Design the seam
**Prevents:** a rewrite that is technically faster but loses at the FFI
boundary.
**Rule:** if boundary cost > 5% of the call's work, coarsen the boundary
or abandon the swap.

## Step 5 — Decision table
**Prevents:** vague recommendations.
**Rule:** every row ends in SWAP / BIND / CONSIDER / KEEP. No "maybe".

## Step 6 — Anti-hype pass
**Prevents:** cool-but-useless languages.
**Rule:** remove any swap whose absence would not make the architecture
worse. If only two languages survive, ship two.

## Step 7 — Roadmap with shadow mode
**Prevents:** cut-over risk.
**Rule:** Phase 1 runs both implementations in parallel behind a flag,
cut over only when the metric wins for N consecutive days.
