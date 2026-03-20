# Lab 7 Submission — GitOps Fundamentals

## Task 1 — Git State Reconciliation

### 1.1: Setup State
**desired-state.txt:**
```text
version: 1.0
app: myapp
replicas: 3
```

### 1.3: Manual Drift Output
```text
Fri 20 Mar 22:11:18 MSK 2026 - ⚠️  DRIFT DETECTED!
Reconciling current state with desired state...
Fri 20 Mar 22:11:18 MSK 2026 - ✅ Reconciliation complete
```

### 1.4: Continuous Reconciliation Evidence (watch command)
<img src="https://i.ibb.co.com/tMs5qr2g/Screenshot-2026-03-20-22-12-47.png" alt="Watch Command Output" width="600"/>

<img src="https://i.ibb.co.com/bgXp26pD/Screenshot-2026-03-20-22-12-50.png" alt="Watch Command Output" width="600"/>

### Analysis
The GitOps reconciliation loop continuously compares the desired state (source of truth) with the current state of the system. By using the `watch` command to run the `reconcile.sh` script every 5 seconds, we simulate an automated operator that detects and corrects configuration drift without human intervention.

---

## Task 2 — GitOps Health Monitoring

### 2.1: Health Check Script (`healthcheck.sh`)
```bash
#!/bin/bash
# healthcheck.sh - Monitor GitOps sync health

DESIRED_MD5=$(md5sum desired-state.txt | awk '{print $1}')
CURRENT_MD5=$(md5sum current-state.txt | awk '{print $1}')

if [ "$DESIRED_MD5" != "$CURRENT_MD5" ]; then
    echo "$(date) - ❌ CRITICAL: State mismatch detected!" | tee -a health.log
    echo "  Desired MD5: $DESIRED_MD5" | tee -a health.log
    echo "  Current MD5: $CURRENT_MD5" | tee -a health.log
else
    echo "$(date) - ✅ OK: States synchronized" | tee -a health.log
fi
```

### 2.2: Health Monitoring Evidence (Drift Detected)
```text
Fri 20 Mar 22:13:14 MSK 2026 - ❌ CRITICAL: State mismatch detected!
  Desired MD5: a15a1a4f965ecd8f9e23a33a6b543155
  Current MD5: 48168ff3ab5ffc0214e81c7e2ee356f5
```

### 2.2: Health Log (`health.log`)
```text
Fri 20 Mar 22:13:14 MSK 2026 - ✅ OK: States synchronized
Fri 20 Mar 22:13:14 MSK 2026 - ❌ CRITICAL: State mismatch detected!
Fri 20 Mar 22:13:14 MSK 2026 - ✅ OK: States synchronized
```

### 2.3: Continuous Monitoring Output (`monitor.sh`)
```text
Starting GitOps monitoring...
--- Check #1 ---
Fri 20 Mar 22:13:35 MSK 2026 - ✅ OK: States synchronized
Fri 20 Mar 22:13:35 MSK 2026 - ✅ States synchronized
...
--- Check #10 ---
Fri 20 Mar 22:14:02 MSK 2026 - ✅ OK: States synchronized
Fri 20 Mar 22:14:02 MSK 2026 - ✅ States synchronized
```

### Analysis & Comparison
- **Checksums (MD5):** MD5 checksums allow for a fast, cryptographic comparison of two files. If the content of `current-state.txt` changes by even a single byte, the hash will differ, immediately signaling the monitoring script that the system is unhealthy.
- **GitOps Tools:** This maps to ArgoCD's "Sync Status." When the MD5 hashes don't match, the UI shows `OutOfSync`. The `reconcile.sh` script acts as the "Sync" action that brings the system back to a `Healthy` state.
