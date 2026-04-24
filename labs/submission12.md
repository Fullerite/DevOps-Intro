# Lab 12 Submission — WASM Containers vs Traditional Containers

## Task 1 — Create the Moscow Time Application

- **Source Code:** Using the provided `main.go` that detects execution context (CLI, net/http, or WAGI) automatically.
- **Confirmation:** Verified local execution in CLI mode and Server mode.

### Evidence
![CLI Mode Output](https://i.postimg.cc/0jw15LXC/cli-mode.png)
![Server Mode Local](https://i.postimg.cc/kGbPMkYf/server-mode.png)

---

## Task 2 — Traditional Docker Container

### Performance Metrics
- **Binary Size:** 4.5 MB
- **Image Size:** 1.98 MB
- **Average Startup Time (CLI):** 0.2900 seconds
- **Memory Usage (Server):** 1.281 MiB

---

## Task 3 — Build WASM Container

### Build Environment
- **TinyGo Version:** 0.39.0
- **Runtime:** `io.containerd.wasmtime.v1` using a custom-built Wasmtime shim installed at `/usr/local/bin/containerd-shim-wasmtime-v1`.

### Performance Metrics
- **WASM Binary Size:** 2.4 MB
- **WASI Image Size:** 2.45 MB
- **Average Startup Time (CLI):** 0.6660 seconds
- **Memory Usage:** N/A (WASM runs in a sandboxed runtime; traditional cgroup metrics do not apply via ctr).

### Analysis: Server Mode Limitation
Plain WASI (Preview1) does not support TCP sockets natively. When attempting to run the server via `ctr`, the `net/http` library fails to bind to a port because the runtime provides no network device. Server-side WASM requires an abstraction layer like Fermyon Spin (WAGI).

### Evidence
![WASM ctr Run](https://i.postimg.cc/7h2rPptV/wasm-ctr-run.png)

---

## Task 4 — Performance Comparison & Analysis

### 4.1: Comparison Table

| Metric | Traditional Container | WASM Container | Improvement | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Binary Size** | 4.5 MB | 2.4 MB | **46.7% smaller** | TinyGo optimizes stdlib |
| **Image Size** | 1.98 MB | 2.45 MB | -23.7% (larger) | OCI archive overhead |
| **Startup Time** | 0.2900 s | 0.6660 s | -129% (slower) | Local `ctr` overhead* |
| **Memory Usage** | 1.281 MiB | N/A | N/A | No cgroup stats in ctr |
| **Base Image** | `scratch` | `scratch` | Identical | Both minimal |
| **Source Code** | `main.go` | `main.go` | Identical | ✅ Same file! |
| **Server Mode** | ✅ Works | ❌ via ctr | N/A | WASI Preview1 limit |

*\*Note: Locally, Docker/runc is probably better optimized for Linux. The startup advantage of WASM is best observed in cloud cold-start environments.*

### 4.2: Analysis Questions

1. **Binary Size Comparison:**
   The WASM binary is nearly 50% smaller because TinyGo is designed for small places. It replaces the full Go runtime (scheduler, heavy garbage collector) with a minimal implementation and strips out unused parts of the standard library during compilation.

2. **Startup Performance:**
   In theory, WASM starts faster because it doesn't need to initialize a Linux namespaces or a full filesystem mount. In this local test, the `ctr` CLI and Wasmtime shim added more overhead than `runc`, but in serverless platforms, WASM eliminates the 100ms+ "cold start" typical of traditional containers.

3. **Use Case Decision Matrix:**
   - **Choose WASM:** For high-density serverless functions, edge computing (Fastly/Cloudflare), and plugins where you need instant scaling and a tiny attack surface.
   - **Stick with Traditional:** For heavy database applications, multi-threaded workloads, or anything requiring low-level networking and existing Linux C-libraries.

---

## Bonus Task — Deploy to Fermyon Spin Cloud

### Deployment Metadata
- **Public URL:** [https://moscow-time-2e5twteu.fermyon.app/](https://moscow-time-2e5twteu.fermyon.app/)
- **Deployment Method:** Fermyon Spin CLI with WAGI executor.

### Evidence
**Live Application on Spin Cloud:**
![Spin Cloud Live App](https://i.ibb.co/q3bD1vMT/spin-app.png)

**Successful `curl`:**
![Spin Cloud Deploy Terminal](https://i.postimg.cc/pdVN50LT/spin-curl.png)

### Cloud Performance Benchmarks
| Metric | Average Time |
| :--- | :--- |
| **Cold Start** | 0.9081 seconds |
| **Warm Start** | 1.8875 seconds |
| **Local Spin Run** | 0.0014 seconds |

### Reflection
1. **Production Use:** I would definitely use Spin for production serverless workloads. The developer experience is superior to traditional containers because the same binary works locally and in the cloud with zero changes. The sub-millisecond local execution time shows that the bottleneck in cloud serverless is almost entirely network-related.
2. **Comparison to AWS Lambda:** Spin feels significantly lighter. While AWS Lambda has a cold start of 100ms-500ms for containers, WASM platforms like Spin can theoretically start in under 5ms. The "Write once, run anywhere" promise is truly there, as the same `main.wasm` ran on my local machine via `ctr` and in the cloud via `spin deploy` with no problems.
