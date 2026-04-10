# Lab 10 Submission — Cloud Computing Fundamentals

## Task 1 — Artifact Registries Research

### 1.1 Cloud Provider Services
- **AWS:** Amazon Elastic Container Registry (ECR)
- **GCP:** Google Artifact Registry
- **Azure:** Azure Container Registry (ACR)

### 1.2 Key Features & Capabilities

**Amazon ECR**
- **Supported Types:** Docker images, OCI artifacts, Helm charts.
- **Key Features:** Cross-region/cross-account replication, Lifecycle policies, Immutable tags.
- **Security:** Scanning via Amazon Inspector. While AWS CodeGuru offers AI-powered code fixes, ECR currently relies on manual or custom-built workflows for patching container base images.
- **Integrations:** Native integration with EKS, ECS, and AWS IAM.

**Google Artifact Registry**
- **Supported Types:** Docker, OCI, OS packages (Apt/Yum), Java, npm, Python, and natively supports Go modules (GA as of March 2025). 
- **Key Features:** Regional/multi-regional storage, granular IAM permissions.
- **Security:** Integrated vulnerability scanning via Container Analysis and Binary Authorization.

**Azure Container Registry (ACR)**
- **Supported Types:** Docker, OCI, Helm.
- **Key Features:** ACR Tasks (automated container building). Available in Basic, Standard, and Premium tiers with strict storage limits per tier before overage charges apply.
- **Security:** Microsoft Defender integration. Notably features Continuous Patching (Copa), which automatically detects and patches OS-level vulnerabilities in images.

### 1.3 Comparison Table

| Feature | AWS ECR | GCP Artifact Registry | Azure ACR |
| :--- | :--- | :--- | :--- |
| **Artifact Variety** | Containers, OCI, Helm | Broadest (Containers, OS packages, Go, npm, Maven, etc.) | Containers, OCI, Helm |
| **Automated Patching** | Manual / Third-party | Manual / Third-party | Yes (Continuous OS Patching via Copa) |
| **Vulnerability Scan**| Amazon Inspector | Container Analysis | Microsoft Defender |
| **Pricing Model** | Per GB stored + Data transfer out | Per GB stored + Data transfer out | Tiered (Basic/Std/Prem) + Storage Overage |

### 1.4 Analysis
**Which registry service would you choose for a multi-cloud strategy and why?**
I would choose GCP Artifact Registry. Unlike AWS ECR and Azure ACR (which are heavily container focused), GCP natively supports universal language packages (npm, PyPI, Maven, and recently Go modules) as well as OS packages. This makes it a true "universal" artifact repository, eliminating the need to pay for third party tools like JFrog Artifactory or Sonatype Nexus in a multi-cloud DevOps pipeline.

---

## Task 2 — Serverless Computing Platform Research

### 2.1 Cloud Provider Services
- **AWS:** AWS Lambda
- **GCP:** Google Cloud Functions (2nd Gen)
- **Azure:** Azure Functions

### 2.2 Key Features & Capabilities

**AWS Lambda**
- **Runtimes:** Node.js, Python, Java, Go, C#, Ruby, plus Custom Runtimes.
- **Execution Model:** Event-driven, HTTP-triggered (via API Gateway or Function URLs).
- **Performance:** Up to 10GB RAM. Recently (late 2025) expanded Ephemeral Storage (`/tmp`) up to 10GB, making it ideal for data-intensive ML inference. Max duration: 15 minutes.
- **Pricing:** 1 million free invocations/month. Priced per 1ms of execution time.

**Google Cloud Functions (2nd Gen)**
- **Runtimes:** Node.js, Python, Go, Java, .NET, Ruby, PHP.
- **Execution Model:** HTTP-triggered, Eventarc. Built on top of Cloud Run.
- **Performance:** Up to 16GB RAM. Max duration: 60 minutes for HTTP triggers, 9 minutes for event-driven.
- **Pricing:** Industry-leading free tier of 2 million free invocations/month**.

**Azure Functions**
- **Runtimes:** C#, Node.js, Python, Java, PowerShell.
- **Execution Model:** Event-driven, HTTP, Timer-triggered.
- **Performance:** Recently introduced the Flex Consumption plan (recommended for Linux), which uses always-ready instances to reduce cold starts. Max duration: 10 minutes (Consumption) or Unlimited (Premium).

### 2.3 Comparison Table

| Feature | AWS Lambda | GCP Cloud Functions (2nd Gen) | Azure Functions |
| :--- | :--- | :--- | :--- |
| **Max Timeout** | 15 Minutes | **60 Minutes** (HTTP) / 9 Mins (Events) | 10 Mins (Consumption) |
| **Cold Start Mitigation**| Provisioned Concurrency / SnapStart | Minimum Instances | **Flex Consumption Plan** (Always-ready) |
| **Storage / Memory** | 10GB RAM / 10GB `/tmp` storage | 16GB RAM | 14GB RAM |
| **Free Tier / Month** | 1 million Invocations | 2 million Invocations | 1 million Invocations |

### 2.4 Analysis
**Which serverless platform would you choose for a REST API backend and why?**
I would choose **AWS Lambda** utilizing Lambda Function URLs. While GCP offers a superior free tier (2 million invocations) and Azure's new Flex Consumption plan minimizes cold starts, AWS Lambda possesses the most mature ecosystem. Supported heavily by third-party IaC tools (Serverless Framework, Terraform) and offering up to 10GB of ephemeral storage for processing heavy payloads, it is the most robust choice for a scalable REST API.

### 2.5 Reflection
**Advantages and Disadvantages of Serverless Computing:**
- **Advantages:** Zero infrastructure management (No OS patching required), true auto-scaling from 0 to 10000s of requests, and highly cost-effective free tiers (e.g., GCP's 2M free requests).
- **Disadvantages:** "Cold starts" (latency spikes when an idle function wakes up, though mitigated by new features like Azure Flex Consumption), difficult local debugging, strict vendor lock-in, and unpredictable costs if traffic spikes uncontrollably.
