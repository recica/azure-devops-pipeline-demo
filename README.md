# Azure DevOps Pipeline Demo

> **In plain English:** This repo takes one of my existing tools (the Azure Governance Analyzer) and shows the full journey code takes in a real company: automatically tested, scanned for security issues, packaged into a container, and deployed to the cloud on a schedule — all triggered automatically whenever code is pushed, with no manual steps.

An end-to-end CI/CD pipeline demo built around [azure-governance-analyzer](https://github.com/recica/azure-governance-analyzer), covering the core AZ-400 (DevOps Engineer Expert) skill areas in one coherent flow instead of disconnected mini-labs: CI, IaC, containerization, security scanning, secrets management, and scheduled cloud deployment.

## What this demonstrates

| AZ-400 skill area | How it's covered here |
|---|---|
| **Continuous Integration** | [`ci.yml`](.github/workflows/ci.yml) — lints (`flake8`) and tests (`pytest`) on every push/PR |
| **Infrastructure as Code** | [`terraform/`](terraform/) — Azure Container Registry, Container Apps Environment, and a scheduled Container App Job, fully declarative |
| **Containerization** | [`Dockerfile`](Dockerfile) — the governance analyzer packaged as a non-root container image, built and scanned in CI |
| **Continuous Deployment** | [`cd.yml`](.github/workflows/cd.yml) — `terraform apply`, image push to ACR, and a job trigger, run automatically after CI passes on `main` |
| **Security in the pipeline (DevSecOps)** | Trivy scans the container image, `tfsec` scans the Terraform config — both wired into CI |
| **Secrets management** | Azure login via **OIDC federated credentials** (`azure/login@v2`), not a stored client secret/password |
| **Deployment pattern** | The analyzer runs as a **scheduled Container App Job** (batch/cron), not a long-running service — the correct Azure primitive for a CLI tool that runs, produces a report, and exits |

## Why a Container App *Job*, not a web app or AKS

The governance analyzer is a CLI batch tool — it runs, checks a subscription, writes a report, and exits. That's exactly what [Azure Container Apps Jobs](https://learn.microsoft.com/azure/container-apps/jobs) are designed for (cron-triggered or manually-triggered batch execution), unlike a long-running Container App (built for HTTP services) or a full AKS cluster (unnecessary orchestration overhead for one scheduled task). Picking the right deployment primitive for the workload — not just "the biggest hammer" — is itself part of what AZ-400 evaluates.

## Project Structure

```text
azure-devops-pipeline-demo/
├── .github/workflows/
│   ├── ci.yml               # lint, test, docker build + Trivy scan, terraform validate + tfsec
│   └── cd.yml                # terraform apply, build & push image to ACR, trigger the job
├── terraform/
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf                # ACR, Log Analytics, Container Apps Environment, Container App Job
│   └── outputs.tf
├── app/                        # containerized governance analyzer (from azure-governance-analyzer)
│   ├── main.py
│   ├── azure_client.py
│   ├── container_run.py       # non-interactive entrypoint for the container (no input() menu loop)
│   ├── data/sample_governance.json
│   └── requirements.txt
├── tests/
│   └── test_governance_findings.py
├── Dockerfile
└── README.md
```

## Running it yourself

### Tests & lint (no Azure needed)

```bash
pip install -r app/requirements.txt pytest flake8
flake8 app/ tests/ --max-line-length=110
pytest tests/ -v
```

### Container (no Azure needed — runs against local sample data)

```bash
docker build -t governance-analyzer:local .
docker run --rm governance-analyzer:local
```

### Terraform (validate only, no cloud connection)

```bash
cd terraform
terraform init -backend=false
terraform validate
```

## About the CD workflow — and why it isn't actually deployed here

[`cd.yml`](.github/workflows/cd.yml) is fully written and would deploy on every push to `main`, but it requires three GitHub repository secrets (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`) tied to an Entra ID App Registration with OIDC federated credentials scoped to this repo. I built and validated everything locally (Docker build/run, `terraform validate`), but did **not** wire up live deployment against my own subscription for this demo — my Azure free trial has a limited runway and I didn't want to spend it running a portfolio demo job on a schedule. The workflow itself is real and would work as-is against any subscription with those secrets configured.

## Related Projects

Part of a broader Azure/security portfolio:

- [azure-governance-analyzer](https://github.com/recica/azure-governance-analyzer) — the CLI tool this repo containerizes and deploys
- [azure-resource-reporter](https://github.com/recica/azure-resource-reporter)
- [microsoft-graph-user-audit](https://github.com/recica/microsoft-graph-user-audit)
- [azure-powershell-toolkit](https://github.com/recica/azure-powershell-toolkit)
- [ai-security-assistant](https://github.com/recica/ai-security-assistant)
