# Lab 11 — Reproducible Builds with Nix

**Student:** [Your Name]  
**Date:** 2026-04-17  
**Platform:** Pop!_OS (Linux)

---

## Task 1 — Build Reproducible Artifacts from Scratch (6 pts)

### 1.1 Nix Installation

```bash
$ nix --version
nix (Determinate Nix 3.17.3) 2.33.3
```

### 1.2 Simple Go Application (`main.go`)

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    fmt.Printf("Built with Nix at compile time\n")
    fmt.Printf("Running at: %s\n", time.Now().Format(time.RFC3339))
}
```

### 1.3 Nix Derivation (`default.nix`)

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule {
  pname = "app";
  version = "1.0.0";
  src = ./.;
  vendorHash = null;   # no external dependencies
}
```

**Explanation:**  
`buildGoModule` is a Nix function that builds Go programs with dependency vendoring. `vendorHash = null` tells Nix there are no third‑party dependencies (only the standard library).

### 1.4 Reproducibility Proof

```bash
$ nix-build
/nix/store/dakhagdwbd63ra3pmffy1pyr2bkiyljq-app-1.0.0

$ ./result/bin/app
Built with Nix at compile time
Running at: 2026-04-17T23:48:41+03:00

$ rm result && nix-build
/nix/store/dakhagdwbd63ra3pmffy1pyr2bkiyljq-app-1.0.0   # identical

$ sha256sum ./result/bin/app
da91c116d4bc422fdac7a9367e5a70981553fda40b5eaa6c7ede5711ee2c52bc  ./result/bin/app
```

**Store path format:**  
`/nix/store/<hash>-<name>-<version>`  
- `<hash>` is a content‑addressable hash derived from all build inputs (source code, compiler, flags, dependencies).  
- `<name>` and `<version>` are package metadata.

### Comparison with Docker (non‑reproducible)

`Dockerfile`:
```dockerfile
FROM golang:1.22
WORKDIR /app
COPY main.go .
RUN go build -o app main.go
```

Build twice:
```bash
$ docker build -t test-app .
$ docker build -t test-app .
$ docker images | grep test-app
test-app1:latest   b95c9f84690d   1.25GB   306MB
test-app2:latest   75358ae42522   1.25GB   306MB
test-app:latest    95408ed0bbb2   1.25GB   306MB
```
**Three different image IDs** from identical source – Docker is not reproducible because:
- Timestamps in layers
- `latest` tag resolution changes over time
- Build metadata (e.g., build time) is embedded

### Why Nix builds are reproducible

- **Sandboxed builds** – no network, no access to host system paths.
- **Content‑addressed store** – same inputs always produce the same store path.
- **Explicit dependencies** – every dependency is pinned by hash.
- **No timestamps** – Nix sets deterministic timestamps (e.g., `1970-01-01`).

---

## Task 2 — Reproducible Docker Images with Nix (4 pts)

### 2.1 Nix Docker Image (`docker.nix`)

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  app = import ./default.nix { inherit pkgs; };
in
pkgs.dockerTools.buildLayeredImage {
  name = "reproducible-app";
  tag = "latest";
  contents = [ app ];
  config = {
    Cmd = [ "${app}/bin/app" ];
  };
}
```

**Build and run:**
```bash
$ nix-build docker.nix
/nix/store/xvjgrh73my0198farxcyw97fx7w5zxxb-reproducible-app.tar.gz

$ docker load < result
Loaded image: reproducible-app:latest

$ docker run reproducible-app:latest
Built with Nix at compile time
Running at: 2026-04-17T20:52:04Z
```

### 2.2 Image Size Comparison

```bash
$ docker images | grep -E "reproducible-app|traditional-app"
reproducible-app:latest   2ea7a29dd11d   11.9MB   4.75MB
traditional-app:latest    0c489bae4d40   3.26MB   1.24MB
```

The Nix‑built image is larger because it includes a full `tzdata` layer (timezone info) that the `scratch`‑based traditional image omits.

### 2.3 Layer Inspection

```bash
$ docker history reproducible-app:latest
IMAGE          CREATED   CREATED BY                         SIZE
f554445545d9   N/A       customisation layer                12.3kB
<missing>      N/A       store path: app-1.0.0              1.81MB
<missing>      N/A       store path: tzdata-2026a           5.33MB

$ docker history traditional-app:latest
IMAGE          CREATED         CREATED BY                   SIZE
c5f0816a4452   2 minutes ago   ENTRYPOINT ["/app"]          0B
<missing>      2 minutes ago   COPY /app/app /app           2.02MB
```

**Differences:**  
- Nix layers are content‑addressed and have no creation timestamps (`CREATED = N/A`).  
- Traditional Docker image includes build timestamps and variable layer sizes.

### Reproducibility Test (Failed)

```bash
$ nix-build docker.nix && sha256sum result
22c7927a172c7fcc66b547e41d45f41da208264d6895ab55b063442ffe6d76cc  result

$ rm result && nix-build docker.nix && sha256sum result
8aa0519d13afa49b5eb24ed78ffaaa4bd3f326aee5f4a3ea58b8e1dc69153f72  result

❌ Not reproducible
```

**Reason for failure:**  
The `default.nix` and `docker.nix` use `import <nixpkgs> {}`, which refers to a **floating channel**. Between builds, the nixpkgs revision may change (e.g., due to channel updates or different evaluation order). This changes the Go toolchain, causing different store paths and final tarball hashes.

**How to fix (time prevented full implementation):**  
Pin `nixpkgs` to a fixed commit (e.g., using `fetchTarball` with a SHA256 hash) or use **Nix Flakes** (Bonus Task). With a pinned nixpkgs, the Docker image becomes bit‑for‑bit reproducible.

**Partial completion:**  
- Docker image successfully built and run.  
- Size comparison and layer inspection completed.  
- Reproducibility requirement **not met** due to floating nixpkgs.

---

## Bonus Task — Modern Nix with Flakes (Not Attempted)

Due to time constraints, the bonus task was not completed. However, using Flakes would lock `nixpkgs` in a `flake.lock` file, guaranteeing that the same revision is used across builds and machines, thus making both the binary and the Docker image truly reproducible.

---

## Conclusion

- **Task 1:** Fully reproducible – Nix produced identical binaries across builds.  
- **Task 2:** Partial – Docker image built successfully but not reproducible due to floating nixpkgs. The issue is understood and would be fixed by pinning dependencies.  
