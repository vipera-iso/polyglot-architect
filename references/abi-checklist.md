# Seam specification checklist

For each language boundary, fill every line. A seam with an unanswered line is
not specified; do not propose the swap.

## Mechanism

- [ ] C ABI (`extern "C"`) — most portable, no runtime dependency
- [ ] cgo — Go↔C, adds cgo call overhead (~100 ns+)
- [ ] wasm-bindgen — sandboxed, adds serialization
- [ ] subprocess + pipe — isolation, high per-call cost
- [ ] shared memory + ring buffer — lowest latency for streams
- [ ] GPU driver API through `dlopen` — no hard link, runtime feature check

Record why the chosen mechanism beats the next-best one by at least 2x in
marshalling cost, or say plainly that it does not and the seam is still worth
it for capability (not speed).

## Ownership

- [ ] Caller allocates, callee writes
- [ ] Callee allocates, caller frees (must match allocator)
- [ ] Arena owned by one side, borrowed by the other
- [ ] Copy at boundary (safe, but costs bandwidth)

Additional rules:
- No pointer from the garbage-collected or managed side may outlive the call
  unless the collector is pinned for that region.
- Every handle crossing the seam is opaque to the other side; only the owning
  side interprets it.
- One function frees, and it is on the same side that allocated.

## Error model

- [ ] Return code + out-param
- [ ] Thread-local last-error
- [ ] Panic=abort at seam (never unwind across FFI)
- [ ] Structured error struct with owned message

Choose one and write the mapping table: seam code → domain error → user-facing
message. A seam that returns `-1` with no message is not acceptable for a
library that reports errors by name.

## Cancellation and timeout

- [ ] Cancellation flag (atomic) polled by the callee
- [ ] Stream/queue teardown on the caller side
- [ ] Deadline propagated into the callee
- [ ] None — call is short enough (state the measured bound)

## Marshalling worksheet

| Call | Payload bytes | Estimated ns | Work done by call | Boundary % |
|------|---------------|--------------|-------------------|------------|
| example: matmul tile | 4 KB | ~200 ns | ~50 µs | 0.4% → fine |
| example: sample token | 64 B | ~50 ns | ~2 µs | 2.5% → fine |
| example: get_config | 1 KB | ~300 ns | ~0.1 µs | 300% → do not cross |

The last row is the one that matters: a cheap call behind a boundary is
strictly worse than the same call in-process. Batch it, cache it, or leave it.
