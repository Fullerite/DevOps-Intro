# Lab 4 Submission — Operating Systems & Networking

## Task 1 — Operating System Analysis

### 1.1 Boot Performance Analysis
```text
Startup finished in 6.232s (firmware) + 1.393s (loader) + 5.690s (kernel) + 5.488s (userspace) = 18.804s 
graphical.target reached after 5.466s in userspace.

Top Blame Services:
48.221s fstrim.service
 2.978s NetworkManager-wait-online.service
 1.791s fwupd.service
```
**Observation:** The system reached the graphical target quickly (~18.8s), but background maintenance tasks like `fstrim.service` took significantly longer to complete in the background.

### 1.2 Process Forensics
```text
Top Memory Processes:
    PID    PPID CMD                         %MEM %CPU
 212461  212460 Telegram --                  6.2  0.3
   4122    4121 /app/lib/librewolf/librewol  5.1  2.8

Top CPU Processes:
    PID    PPID CMD                         %MEM %CPU
 241217    4243 /app/lib/librewolf/librewol  2.4 14.0
 241548  241439 /usr/share/code/code --type  2.3  9.7
```
**Answer:** The top memory-consuming process is the **Telegram** messaging app, consuming 6.2% of system RAM.
**Pattern:** Web browsers (LibreWolf) and Electron-based apps (VS Code, Telegram) dominate both CPU and memory consumption.

### 1.3 Service Dependencies
```text
multi-user.target
● ├─com.system76.PowerDaemon.service
● ├─com.system76.Scheduler.service
● ├─dbus-broker.service
```
**Observation:** The dependency tree shows Pop_OS-specific tuning daemons (`com.system76.*`) loading alongside standard networking services required for the multi-user target.

### 1.4 User Sessions
```text
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
fullerit tty1     -                16Feb26  6days  7:36m 16:08  cosmic-

reboot   system boot  6.18.7-76061807- Mon Feb 16 13:06   still running
```

### 1.5 Memory Analysis
```text
               total        used        free      shared  buff/cache   available
Mem:            13Gi       9.9Gi       818Mi       255Mi       3.8Gi       3.4Gi
Swap:           13Gi       913Mi        12Gi
MemTotal:       13980452 kB
MemAvailable:    3601724 kB
SwapTotal:      13980668 kB
```
**Observation:** Out of roughly 14GB of total RAM, about 10GB is currently in use. The system relies on a 13GB swap file to ensure stability under heavy loads.

---

## Task 2 — Networking Analysis

### 2.1 Network Path Tracing & DNS
```text
traceroute to github.com (140.82.121.XXX), 30 hops max
 1  _gateway (192.168.3.XXX)  17.602 ms
 2  10.242.1.XXX (10.242.1.XXX)  344.889 ms
 3  10.250.0.XXX (10.250.0.XXX)  344.785 ms
 5  188.170.164.XXX (188.170.164.XXX)  344.657 ms
11  netnod-ix-ge-b-sth-1500.inter.link (194.68.128.XXX)  42.760 ms
18  cust-sid435.r1-fra3-de.as5405.net (45.153.82.XXX)  59.652 ms

;; ANSWER SECTION (from dig):
github.com.             1497    IN      A       140.82.121.XXX
```
**Path Insights:** The traffic routes through a local gateway (`192.168.3.XXX`), then hits internal ISP nodes (`10.x.x.x`), before entering public routing frameworks across European exchanges (like `netnod` in Stockholm and nodes in Frankfurt `fra3`). Many intermediate nodes drop ICMP trace packets (indicated by `* * *`), which is standard firewall behavior.

### 2.2 Packet Capture
```text
listening on any, link-type LINUX_SLL2 (Linux cooked v2)
13:00:38.833457 lo    In  IP 127.0.0.1.37632 > 127.0.0.53.53: 927+ [1au] A? api.github.com. (43)
13:00:38.833664 lo    In  IP 127.0.0.53.53 > 127.0.0.1.37632: 927 1/0/1 A 140.82.121.XXX (59)
13:00:42.389229 lo    In  IP 127.0.0.1.55597 > 127.0.0.53.53: 52089+ [1au] A? dns10.quad9.net. (44)
```
**Example DNS Query:** A local application queried the local `systemd-resolved` stub resolver (`127.0.0.53:53`) for `api.github.com`. The resolver responded rapidly with the IP `140.82.121.XXX`.

### 2.3 Reverse DNS Lookup
```text
;; QUESTION SECTION:
;4.4.8.8.in-addr.arpa.          IN      PTR
;; ANSWER SECTION:
4.4.8.8.in-addr.arpa.   6320    IN      PTR     dns.google.

;; QUESTION SECTION:
;2.2.1.1.in-addr.arpa.          IN      PTR
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN
```
**Comparison:** `8.8.4.4` successfully resolves to `dns.google` because Google maintains a valid PTR record for their DNS server. `1.1.2.2` returns `NXDOMAIN` (Non-Existent Domain) because APNIC does not have a PTR record mapping that IP back to a hostname.
