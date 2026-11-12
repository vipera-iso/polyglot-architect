# Cross-runtime concurrency compatibility

A swap that changes the concurrency model is the largest source of
production bugs in polyglot systems. Check this **before** designing the
seam.

## Caller → callee risk matrix

| Caller | Callee | Risk | Mitigation |
|---|---|---|---|
| Async (tokio) | Sync C lib | Blocks runtime worker | `spawn_blocking`, dedicated pool |
| Async Rust | Async Go | Two runtimes fight for threads | One process = one runtime; IPC |
| Async Rust | Async Python (asyncio) | GIL + event loop mismatch | Subprocess, or PyO3 + GIL release |
| Go (goroutines) | Sync C | Scheduler stalls, affinity | Short C calls, `runtime.LockOSThread` |
| Go | Async Rust | Nested runtime impossible | C ABI + call blocking functions |
| Python (GIL) | Async Rust | GIL blocks other threads | `py.allow_threads {}` |
| Python (GIL) | Sync C | GIL held during C call | `Py_BEGIN_ALLOW_THREADS` in C |
| Java (threads) | Sync C | JNI holds thread | Thread pool, no shared mutable |
| Node (event loop) | Sync C | Blocks event loop | `worker_threads` or N-API async |
| .NET (Task) | Sync C | Blocks thread pool | `Task.Run`, async P/Invoke |
| Single-threaded | Multi-threaded callee | Data races if shared | Arena-per-thread |
| Multi-threaded | Single-threaded callee | Serialization bottleneck | Worker pool of instances |

## State and ownership across runtimes

For **stateful** units (KV cache, connection pool, session), the seam must
additionally specify:

- **Who owns the state** — one side, or shared with lock?
- **How state is created / destroyed** — init / shutdown?
- **Cancellation mid-update** — partial state allowed?
- **Thread affinity** — bound to a specific thread or runtime?
- **Memory ordering** — cross-runtime synchronization required?

## Cancellation patterns

- **Cooperative flag** — `&AtomicBool` checked every K iterations.
- **FD close** — closes descriptor, callee gets EBADF. Works cross-process.
- **Scope token** — Tokio `CancellationToken`, Go `context.Context`, .NET
  `CancellationToken`.
- **Abort / kill** — subprocess only. Never same-process.

Choose based on **call duration**:
- < 1 ms — cancellation often not worth implementing.
- 1 ms–100 ms — cooperative flag or scope token.
- > 100 ms — full cancellation + partial-state handling.

## Thread-safety checklist

- [ ] Does the callee mutate global state? Is it thread-safe?
- [ ] Does the caller hold a lock across the boundary? (usually bad)
- [ ] Are there `unsafe` blocks in the seam? (Rust) Audited?
- [ ] Can the callee call back into the caller? (re-entrancy)
- [ ] Are panics / exceptions contained at the seam?
