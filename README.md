# 🚀 Terraform Advanced Infrastructure CI Pipeline

This project demonstrates an advanced Infrastructure-as-Code (IaC) setup using **Terraform**, **Terragrunt**, and a robust CI pipeline powered by **GitHub Actions**.

It automates infrastructure validation, static security analysis, policy enforcement, and cost estimation for multiple environments such as `dev`, `stage`, and `prod`.

---

## 📦 Features

- ✅ **Terraform & Terragrunt Support**  
  Modular and environment-specific infrastructure using Terragrunt over Terraform modules.

- 🔍 **Formatting & Validation**  
  Ensures HCL and Terraform code is clean, consistent, and syntactically valid using `terraform fmt`, `terragrunt hclfmt`, and `terragrunt validate`.

- 🛡️ **Static Analysis with Checkov**  
  Detects security and compliance misconfigurations from Terraform plans using [Checkov](https://www.checkov.io/).

- 🔐 **Custom Policy Support**  
  Supports custom-written Checkov policies for organization-specific security/compliance checks.

- 💰 **Cost Estimation with Infracost**  
  Generates cost breakdowns and HTML reports for proposed changes using [Infracost](https://www.infracost.io/).

- 🧪 **Terratest (Optional)**  
  Validates deployed infrastructure using Go-based integration tests locally or via LocalStack.

---

## 🔁 CI/CD Overview

Each environment (`dev`, `stage`, `prod`) has its own GitHub Actions workflow triggered by pull requests.  

### CI Pipeline Tasks:

1. **Checkout Code**
2. **Format Terraform & HCL Code**
3. **Terragrunt Init + Validate + Plan**
4. **Convert Terraform Plan to JSON**
5. **Run Checkov Analysis**
6. **Run Custom Policies (if defined)**
7. **Generate Infracost Breakdown**
8. **Generate HTML Cost Report & Upload**

---

## 🛠️ Tech Stack

| Tool        | Purpose                                   |
|-------------|-------------------------------------------|
| Terraform   | Infrastructure provisioning               |
| Terragrunt  | Manage Terraform modules & environments   |
| GitHub Actions | CI workflows                           |
| Checkov     | Static security & compliance analysis     |
| Infracost   | Cloud cost estimation                     |
| Terratest   | Infrastructure testing (optional)         |
| LocalStack  | Local AWS testing (optional)              |

---

## 🔐 Required Secrets

| Secret Name         | Description                          |
|---------------------|--------------------------------------|
| `INFRACOST_API_KEY` | API key from Infracost for CI usage |

---

## 📎 Usage

1. Fork the repo and clone it.
2. Update your `infrastructure/envs/{env}` with your configurations.
3. Open a pull request — CI automatically validates and analyzes changes.
4. Review the comments and cost breakdown posted by the CI.
5. Merge once compliant and approved.

---

## 📄 License

MIT © 2025 [Your Name or Org]

---

> 💡 Pro Tip: Extend this setup with [Spacelift](https://spacelift.io/) or [Atlantis](https://www.runatlantis.io/) for full GitOps control of Terraform plans and applies.
