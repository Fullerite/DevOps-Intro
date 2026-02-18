# Lab 3 Submission — CI/CD with GitHub Actions

## Task 1 — First GitHub Actions Workflow

### Evidence
- **Run Link:** https://github.com/Fullerite/DevOps-Intro/actions/runs/22154110125
- **Trigger:** This workflow was triggered automatically by a `push` event (Commit `cebe030`).

### Analysis
GitHub Actions uses a runner (a virtual machine) to execute automated tasks. In this task, the runner initialized, downloaded the repository code, and executed the steps defined in the YAML file.
- **Jobs:** The `system-info` job group.
- **Steps:** Individual actions like "Hello World" and "System Information."
- **Runner:** A GitHub-hosted Ubuntu Linux instance.

---

## Task 2 — Manual Trigger + System Information

### Evidence
- **Run Link:** https://github.com/Fullerite/DevOps-Intro/actions/runs/22154705279
- **Trigger:** Manual from GitHub Actions UI

### Manual Trigger Evidence
I successfully performed a manual trigger using the `workflow_dispatch` event. In the GitHub Actions UI, I used the "Run workflow" button to trigger a run on the `feature/lab3` branch.

### Gathered System Information (from Manual Run #3)
- **OS/Kernel:** Linux 6.14.0-1017-azure (#17~24.04.1-Ubuntu)
- **CPU Cores:** 4
- **CPU Model:** Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz
- **Memory:** 15Gi Total, 14Gi available
- **Disk Space:** 145G total (`/dev/root`) with 92G available

### Trigger Comparison
- **Automatic (Push):** Best for standard CI practices where code is validated immediately upon change.
- **Manual (Dispatch):** Best for maintenance, optional deployments, or running diagnostics (like this lab) without needing to change code.

### Analysis of Runner Environment
The runner is hosted on Microsoft Azure (as indicated by the kernel name). It is a powerful environment with 4 modern Xeon cores and 15GB of RAM, providing a consistent and isolated environment for DevOps pipelines.

---

## Workflow Configuration (YAML)

```yaml
name: Lab 3 CI Workflow
on:
  push:
    branches: [ main, feature/lab3 ]
  workflow_dispatch:
jobs:
  system-info:
    runs-on: ubuntu-latest
    steps:
      - name: Task 1 - Hello World
        run: echo "The pipeline is working"
      - name: Task 2 - System Information
        run: |
          echo "=== OS Information ==="
          uname -a
          echo "=== CPU Information ==="
          nproc
          lscpu | grep "Model name"
          echo "=== Memory Information ==="
          free -h
          echo "=== Disk Space ==="
          df -h
          echo "=== GitHub Runner Details ==="
          echo "Runner OS: ${{ runner.os }}"
          echo "Workflow: ${{ github.workflow }}"
```
