# Seam specification — all FFI mechanisms

Fill every section for each SWAP or BIND row. Missing fields = incomplete
spec = do not proceed to Phase 1.

## Mechanism catalog

### Same-process
- [ ] **C ABI (`extern "C"`)** — Rust↔C, C++↔C, Zig↔C, Go (via cgo).
  Most portable. ~10–20 ns.
- [ ] **cgo** — Go↔C. ~100–200 ns. Blocks goroutine scheduler during call.
- [ ] **JNI** — Java/Kotlin↔C/C++. ~50–100 ns. Exception mapping required.
- [ ] **N-API** — Node↔C/C++. ~100–200 ns. Thread-safe, callback-heavy.
- [ ] **PyO3 / Cython** — Python↔Rust/C. ~1 µs. Release GIL where safe.
- [ ] **ctypes / cffi** — Python↔C. ~1–5 µs. No GIL release by default.
- [ ] **wasm-bindgen / wasmtime** — JS↔wasm, any-host↔wasm. ~1–5 µs.
- [ ] **cbindgen / bindgen** — headers across language pairs.

### Cross-process
- [ ] **Subprocess + pipe** — ~1 ms. Best isolation.
- [ ] **gRPC / REST localhost** — ~100 µs–ms.
- [ ] **Message queue** (NATS, RabbitMQ, Kafka) — ~ms. Durable.
- [ ] **Shared memory + ring buffer** — ~50–100 ns. Best for streams.
- [ ] **Unix domain socket** — ~10–50 µs. Local, cheap.

### Cross-host
- [ ] **Network RPC** — ~ms. Only when workload justifies partition.

## Ownership

- [ ] Caller allocates, callee writes.
- [ ] Callee allocates, caller frees (**must match allocator**).
- [ ] Arena owned by one side, borrowed by the other.
- [ ] Copy at boundary (safe, costs bandwidth).
- [ ] Refcounted shared object (Arc / shared_ptr) with explicit cross-
      runtime rule.

State the exact allocator. **`malloc` from C cannot be freed by Rust's
global allocator** — match allocators, use `libc::free`, or copy.

## Error model

- [ ] Return code + out-param.
- [ ] Thread-local last-error.
- [ ] Panic = abort at seam (never unwind across FFI).
- [ ] Structured error struct with owned message (caller frees).
- [ ] Exception mapping (Java↔C, Python↔C, C#↔C).

## Threading & cancellation

- [ ] Sync callee from async caller — thread pool / `spawn_blocking`.
- [ ] Async callee from sync caller — nested runtime or dedicated loop.
- [ ] Who owns the runtime? (tokio, goroutine scheduler, GIL, JVM).
- [ ] Thread affinity — can the callee run on any thread?
- [ ] Cancellation — how caller aborts in-flight work (flag, fd close,
      context token).
- [ ] Timeouts — enforced by caller or callee?

See `concurrency-models.md` for the cross-runtime risk matrix.

## Marshalling worksheet

| Call | Payload bytes | Est. ns | Work per call | Boundary % | Verdict |
|------|---------------|---------|---------------|------------|---------|
| matmul tile | 4 KB | 200 | 50 µs | 0.4% | fine |
| sample token | 64 B | 50 | 2 µs | 2.5% | fine |
| get_config | 1 KB | 300 | 0.1 µs | 300% | do not cross |
| batch of 64 tokens | 4 KB | 200 | 128 µs | 0.15% | fine |

If any row exceeds 5% → batch, stream, or drop the swap.

## Full seam template

```
Boundary:        <langA> ↔ <langB> via <module/crate/service>
Mechanism:       <C ABI / cgo / JNI / PyO3 / N-API / wasm-bindgen / ...>
Allocator:       <who allocates, who frees, which allocator>
Ownership:       <borrowed / owned / arena / refcounted / copied>
Error model:     <return code / Result / exception mapping / abort>
Threading:       <sync/async, runtime owner, affinity>
Cancellation:    <how caller aborts in-flight>
Marshalling:     <ns/call, bytes/call, % of call work>
Test oracle:     <conformance / parity suite name>
```
