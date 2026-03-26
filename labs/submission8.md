# Lab 8 Submission — Site Reliability Engineering (SRE)

## Task 1 — Key Metrics for SRE and System Analysis

### 1.1: Resource Consumption Analysis

**Top 3 Most Consuming Applications:**

| Metric | Top 1 | Top 2 | Top 3 |
| --- | --- | --- | --- |
| **CPU Usage** | LibreWolf | cosmic-comp | htop |
| **Memory Usage** | LibreWolf | cosmic-comp | Telegram |
| **I/O Usage** | rsyslogd | Docker (Volumes) | systemd-journald |

**iostat Output Snippet:**
```text
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.46    3.17    1.13    0.03    0.00   95.21

Device            r/s     rkB/s     w/s     wkB/s    %util
nvme0n1          1.70     73.01   13.64    707.77     0.22
```

---


### 1.2: Disk Space Management

**Top 3 Largest Files in `/var`:**
1. `1.2G` — `/var/log/syslog`
2. `931M` — `/var/lib/docker/volumes/.../me-...-big-Data.db`
3. `913M` — `/var/lib/docker/volumes/.../me-...-big-Data.db`

**Analysis:**
The system's primary partition is at 83% capacity, with 345GB used out of 440GB. While the majority of the space is occupied by my personal data in the home directory, the `/var` directory occupies a significant 27GB. Within `/var`, Docker volumes are the dominant consumer, accounting for 22GB (over 80% of `/var`). The 1.2GB `syslog` file is also notable, as it indicates a very high volume of system events.

**Optimization Reflection:**
To improve reliability, I would implement more aggressive log rotation for `syslog` and perform a `docker system prune --volumes` to reclaim space from unused containers. Reducing disk saturation below 80% is a key SRE objective to prevent filesystem performance degradation.

---

## Task 2 — Practical Website Monitoring Setup

**Target Website:** `https://www.google.com`

### 2.1: Monitoring Configuration
I configured an API Check to verify basic 200 OK availability and a Browser Check using Playwright to validate that the page title contains "Google."

**Browser Check Configuration:**
![Browser Check](https://i.ibb.co.com/VpkhWnC1/Screenshot-2026-03-26-20-53-13.png)

### 2.2: Successful Run Evidence
All checks are executing successfully from global runners (Frankfurt/London).
![Browser Check Success](https://i.ibb.co.com/q3LBZh4B/Screenshot-2026-03-26-20-55-39.png)

### 2.3: Alerting and Dashboard
I configured email alerts to my personal email to trigger immediately upon any check failure, ensuring fast error detection.

**Alert Settings:**
![Alert Settings](https://i.ibb.co.com/WpKpkyvC/Screenshot-2026-03-26-20-55-24.png)

**Dashboard Overview:**
![Dashboard Overview](https://i.ibb.co.com/G38K35Kt/Screenshot-2026-03-26-20-55-08.png)

### Analysis & Reflection
I chose these specific checks to cover both "Availability" (API Check) and "Correctness" (Browser Check). A site might return a 200 status but show a blank page; the Browser Check ensures the user actually sees the expected content. This setup helps maintain the Service Level Objective (SLO) by providing real-time visibility into the user experience.
