# Lab 6 Submission — Container Fundamentals with Docker

## Task 1 — Container Lifecycle & Image Management

### Image & Container Status
- **Ubuntu Image Size:** 119MB (Disk Usage), 31.7MB (Content Size)
- **Exported Tar File Size:** 31MB (`ubuntu_image.tar`)

### Removal Attempt
When attempting to remove the image while the container existed, the following error occurred:
`Error response from daemon: conflict: unable to delete ubuntu:latest (must be forced) - container 187bda306919 is using its referenced image d1e2e92c075e`

### Analysis
- **Dependency:** Image removal fails because a container is a "writable layer" sitting on top of the read-only image layers. Even if the container is stopped, Docker maintains this dependency to ensure the container's filesystem remains intact.
- **Export Content:** The exported `.tar` file contains all the filesystem layers of the image, the configuration JSON file (metadata like environment variables and entry points), and the manifest file.

---

## Task 2 — Custom Image Creation & Analysis

### Custom Content Verification
- **Original Nginx:** Successfully verified via curl (Welcome to nginx! page).
- **Custom HTML:** `<html><head><title>The best</title></head><body><h1>website</h1></body></html>`
- **Verification:** Successfully verified custom content via curl after `docker cp`.

### Filesystem Changes (`docker diff`)
```text
C /usr/share/nginx/html/index.html
A /run/nginx.pid
A /var/cache/nginx/client_temp
...
```

### Analysis
- **Diff Explanation:** `C` (Changed) indicates the `index.html` was modified. `A` (Added) indicates files created during runtime, such as the process ID file and cache directories.
- **Reflection:** `docker commit` is fast for debugging or saving a specific state, but it is "opaque" (hard to see what changed) and not easily reproducible. **Dockerfiles** are the industry standard because they provide a documented, version-controlled, and automated way to build images.

---

## Task 3 — Container Networking & Service Discovery

### Connectivity and DNS Evidence
- **Ping Output:** 
```text
64 bytes from 10.200.1.3: seq=0 ttl=64 time=0.065 ms
3 packets transmitted, 3 packets received, 0% packet loss
```
- **NSLookup Output:**
```text
Name:   container2
Address: 10.200.1.3
```

### Analysis
- **Internal DNS:** Docker runs an embedded DNS server at `127.0.0.11`. When containers are on a user-defined network, this server maps container names to their internal IP addresses, allowing communication by name.
- **Network Advantages:** User-defined bridge networks provide automatic service discovery (DNS) and better security isolation compared to the default bridge network.

---

## Task 4 — Data Persistence with Volumes

### Persistence Evidence
- **Custom Content:** `<html><body><h1>Persistent Data</h1></body></html>`
- **Verification:** After deleting the `web` container and starting `web_new`, the curl output confirmed the data survived:
`<html><body><h1>Persistent Data</h1></body></html>`

### Analysis
- **Importance:** Data persistence is critical because containers are ephemeral. Without volumes, all data (like databases or user uploads) would be lost whenever a container is updated or restarted.
- **Storage Comparison:** 
  - **Volumes:** Managed by Docker; best for persistent app data.
  - **Bind Mounts:** Maps a specific host folder; best for sharing source code during development.
  - **Container Storage:** Ephemeral and disappears when the container is deleted.
