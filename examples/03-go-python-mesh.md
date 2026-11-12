# Example 03 — Go microservice mesh + Python ML sidecar

**Repo shape:** 3 Go services + 1 Python gRPC sidecar.
**Question:** "Rewrite Python in Rust?"

## 2. Heat map

| Unit | Cold % | Warm % | Hot % | Evidence |
|---|---|---|---|---|
| `gateway` | 0 | 30 | 0 | pprof, 1k req/s |
| `auth` | 0 | 10 | 0 | pprof |
| `feature-store` | 0 | 25 | 0 | pprof |
| `ml-sidecar` | 5 | 20 | **45** | py-spy + perf |

## 3. Decision table

| # | Unit | Lang | Proposed | Property | Verdict |
|---|---|---|---|---|---|
| 1 | `ml-sidecar` inference | Python | **Bind ONNX Runtime** | matmul inside model | **BIND** |
| 2 | `ml-sidecar` preprocess | Python | — | small | **KEEP** |
| 3 | `gateway` | Go | — | warm | **KEEP** |
| 4 | `auth` | Go | — | warm | **KEEP** |
| 5 | `feature-store` | Go | — | warm | **KEEP** |

**Anti-hype:** did **not** propose rewriting Python in Rust. py-spy shows
the hot leaf is inside numpy/ONNX — already C++. The language of the
*wrapper* is irrelevant; the fix is swapping the model runtime.

## 6. Roadmap

### Phase 1 — swap torch.load → ONNX Runtime
- Metric: p99 inference latency
- Shadow: load both, compare outputs on golden set
- Cut-over: p99 −40%, output diff < 1e-5

### Phase 2 — none.
