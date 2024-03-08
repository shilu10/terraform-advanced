# 🚀 Advanced Terraform Infrastructure: CI with GitHub Actions & CD via Spacelift

This project sets up a robust Infrastructure-as-Code (IaC) pipeline using **Terraform**, **Terragrunt**, **GitHub Actions**, and **Spacelift**.

It combines static analysis, policy enforcement, cost estimation, and optional infrastructure testing — all in CI — while delegating multi-environment deployments to Spacelift.

---

## 🏗️ Application Architecture

This infrastructure powers a modular AWS-based serverless system:

ImageUploaderLambda
↓
[S3 + SQS]
↓
ImageProcessorLambda
↓
[RDS + S3 (processed)]



- **ImageUploaderLambda**: Receives image + metadata via Function URL.
- **S3 Bucket**: Stores raw images.
- **SQS Queue**: Sends metadata for asynchronous processing.
- **ImageProcessorLambda**: Consumes metadata from SQS, enriches and stores:
  - Structured metadata → **Amazon RDS**
  - Processed image → **S3**

---

## ⚙️ CI/CD Overview

### 🔄 CI: GitHub Actions (Pull Request Based)

GitHub Actions run validations **per environment** (`dev`, `stage`, `prod`) based on PR changes.

**CI Pipeline Tasks:**

| Step                | Description                                      |
|---------------------|--------------------------------------------------|
| ✅ Checkout         | Clone repository and prepare workspace           |
| 🔧 Format Check     | `terraform fmt`, `terragrunt hclfmt`             |
| 🔍 Validation       | `terragrunt validate` per module                 |
| 🧱 Plan & JSON      | `terragrunt plan`, then convert to JSON          |
| 🛡️ Checkov Scan    | Static security scans (built-in + custom rules) |
| 📜 Rego Policies    | Optional OPA-based policy enforcement            |
| 💰 Infracost        | Cost breakdown and HTML report generation       |
| 🧪 Terratest (opt)  | Go-based infrastructure tests via LocalStack     |

> CI runs on `pull_request` and `workflow_dispatch` triggers.  
> Reports and artifacts are uploaded as part of the CI job.

---

### 🚀 CD: Spacelift (Multi-Environment Deployment)

Actual infrastructure **deployment is handled by Spacelift** using GitOps principles.

- Each environment (`dev`, `stage`, `prod`) is mapped to a **Spacelift stack**
- Triggered when PRs are merged into the main branches
- Handles `plan`, `apply`, drift detection, and approvals
- Policies, previews, and RBAC are enforced through Spacelift

Spacelift automatically detects changes via:
- Pushes to tracked branches
- Changes under specific Terragrunt paths

---

## 🧪 Terratest Integration (Optional)

Terratest can be enabled to run against infrastructure provisioned in CI using **LocalStack**.

It provides:
- End-to-end validation of SQS, Lambda, S3, RDS interactions
- Test orchestration in Go
- Full lifecycle: `apply → test → destroy`

Example:
```go
terragrunt.RunTerragrunt(t, options, "apply")
// run validations...
defer terragrunt.RunTerragrunt(t, options, "destroy")
```


## 🔐 Required GitHub Secrets

| Secret Name         | Purpose                                  |
|---------------------|------------------------------------------|
| `INFRACOST_API_KEY` | Infracost API key for cost estimation    |
| `LOCALSTACK_AUTH_TOKEN` | Localstack cloud key for pro edition    |


---

## 🚀 Getting Started

1. **Fork & Clone** this repository.
2. Update your `infrastructure/envs/{env}` configuration as needed.
3. Set the `INFRACOST_API_KEY` in GitHub Secrets.
4. Push a branch and open a Pull Request.
   - GitHub Actions CI will validate and analyze the changes.
5. Upon merging:
   - **Spacelift** will deploy the infrastructure into the targeted environment.

---

## 🛠️ Tech Stack

| Tool         | Purpose                                   |
|--------------|-------------------------------------------|
| Terraform    | Infrastructure provisioning               |
| Terragrunt   | Wrapper for managing modules & environments |
| GitHub Actions | Continuous Integration for PR validation |
| Spacelift    | GitOps-based Infrastructure Deployment    |
| Checkov      | Static security and compliance analysis   |
| Infracost    | Cloud cost estimation                     |
| Terratest    | Infrastructure testing via Go (optional)  |
| LocalStack   | Local AWS simulation (CI testing)         |



---

> 💡 **Pro Tip:** This setup can be extended with [Atlantis](https://www.runatlantis.io/), [DriftCTL](https://github.com/snyk/driftctl), or [OPA Gatekeeper](https://github.com/open-policy-agent/gatekeeper) for even stronger IaC governance.
