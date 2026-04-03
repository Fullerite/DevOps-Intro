# Lab 9 Submission — Introduction to DevSecOps Tools

## Task 1 — Web Application Scanning with OWASP ZAP

### 1.3: Scan Results Analysis
- **Medium Risk Vulnerabilities Found:** 2
- **Most Interesting Findings:**
    1. **Content Security Policy (CSP) Header Not Set:** This is a critical defense-in-depth mechanism. Without it, the application is much more vulnerable to Cross-Site Scripting (XSS) and data injection attacks.
    2. **Cross-Domain Misconfiguration:** The scan detected an overly permissive CORS policy (`Access-Control-Allow-Origin: *`), which could allow malicious third-party sites to interact with the application inappropriately.

### Security Headers Status
- **Present:** None identified as systemic.
- **Missing:** Content-Security-Policy (CSP), X-Content-Type-Options, and Strict-Transport-Security (HSTS).
- **Why it matters:** These headers provide instructions to the browser to enable security features. Missing them makes the "Juice Shop" an easy target for common web attacks like clickjacking and protocol downgrades.

### Evidence
![ZAP Alert Summary](https://i.postimg.cc/vZzmH39t/Screenshot-2026-04-03-11-41-42.png)

### Analysis
The most common vulnerabilities in web applications are related to **Security Misconfigurations** (like missing headers) and **Insecure Component Dependencies**. Automated scanners like ZAP are essential for identifying these "low-hanging fruit" vulnerabilities that attackers often script for.

---

## Task 2 — Container Vulnerability Scanning with Trivy

### 2.2: Identify Key Findings
- **CRITICAL Vulnerabilities:** 10
- **HIGH Vulnerabilities:** 49
- **Vulnerable Packages:**
    1. **libc6** (CVE-2026-4046) - High severity Denial of Service vulnerability in the system library.
    2. **base64url** (NSWG-ECO-428) - High severity Out-of-bounds Read in a Node.js library.
- **Most Common Vulnerability Type:** Library-level vulnerabilities (specifically in Node.js packages) and OS-level vulnerabilities in the Debian base image.

### Evidence
![Trivy Scan Results](https://i.postimg.cc/nz6Fw5bZ/Screenshot-2026-04-03-11-26-59.png)

### Analysis
Container image scanning is critical before production deployment because containers often bundle an entire OS and dozens of third-party libraries. Even if your own code is secure, a single vulnerable library like `libc6` or a Node package can provide an entry point for an attacker to compromise the entire container environment.

### Reflection: CI/CD Integration
In a professional DevSecOps pipeline, I would integrate these tools as follows:
1. **Trivy:** Run every time a new container image is built. I would configure the pipeline to "Fail" if any CRITICAL vulnerabilities are found, preventing the image from being pushed to the registry.
2. **OWASP ZAP:** Run in a staging environment after deployment, but before the release is public. This ensures that the live configuration of the app is tested for web-based flaws.
