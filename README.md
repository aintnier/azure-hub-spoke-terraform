# Azure Hub-and-Spoke Topologies - Azure & Terraform Project

[![Terraform CI](https://github.com/aintnier/azure-hub-spoke-terraform/actions/workflows/ci.yml/badge.svg)](https://github.com/aintnier/azure-hub-spoke-terraform/actions/workflows/ci.yml)

A portfolio project demonstrating the evolution of **Hub-and-Spoke network topologies** on Microsoft Azure - from manual VNet Peering to policy-driven automation with AVNM to fully managed SD-WAN with Virtual WAN.

All infrastructure is provisioned via **Terraform**, automated through **GitHub Actions CI/CD pipelines**.

---

## Architecture - 3 Progressive Layers

| Layer | Technology | Key Concept |
|-------|-----------|------------|
| [Layer 1](layer1-manual-peering/) | Manual VNet Peering | Traditional approach, full control |
| [Layer 2](layer2-avnm/) | Azure Virtual Network Manager | Tag-based dynamic network groups |
| [Layer 3](layer3-vwan/) | Azure Virtual WAN | Fully managed hub, Routing Intent |

All layers share the same logical pattern: spoke-to-spoke traffic is routed through a central **Azure Firewall (Standard)** acting as the NVA.

```
                        ┌─────────────────────────────────────────┐
                        │                 Hub VNet                │
                        │                                         │
                        │           ┌─────────────────┐           │
                        │           │  Azure Firewall │           │
                        │           │   (Standard)    │           │
                        │           └────────┬────────┘           │
                        │                    │                    │
                        └────────────────────┼────────────────────┘
                              ▲              │             ▲
                  peering /   │        UDR / Routing       │   peering /
                  connection  │          Intent            │   connection
                              │     (all traffic → FW)     │
               ┌──────────────┴──┐                ┌────────┴─────────┐
               │   Spoke 1 VNet  │                │   Spoke 2 VNet   │
               │                 │                │                  │
               │   ┌──────────┐  │                │  ┌──────────┐    │
               │   │  VM 1    │  │                │  │  VM 2    │    │
               │   └──────────┘  │                │  └──────────┘    │
               └─────────────────┘                └──────────────────┘

         Spoke 1 ◄──── all traffic ────► Firewall ◄──── all traffic ────► Spoke 2
                                            │
                                    Internet egress
```

---

## Phase 0: Project Foundation (OIDC & State)

Before deploying the progressive network layers, a robust, enterprise-grade Azure Foundation was established via the Azure CLI.

### 1. Zero-Trust Authentication (OIDC)
Instead of relying on legacy, long-lived client secrets, this project exclusively uses **OpenID Connect (OIDC)** for GitHub Actions to authenticate to Azure.
- An Entra ID App Registration (`github-actions-hub-spoke`) was created with a Service Principal assigned the **Contributor** role.
- Federated credentials were created for the `main` branch, `pull_request` events (for CI validation), and the `production` environment (for actual deployments).

```bash
# Creating the App Registration and assigning Subscription Contributor role
az ad app create --display-name "github-actions-hub-spoke"
az ad sp create --id <APP_ID>
az role assignment create --assignee <SP_ID> --role Contributor --scope /subscriptions/<SUB_ID>

# Generating the zero-trust OIDC Federated Credential for the main branch
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{"name":"github-actions-main","issuer":"https://token.actions.githubusercontent.com","subject":"repo:aintnier/azure-hub-spoke-terraform:ref:refs/heads/main","audiences":["api://AzureADTokenExchange"]}'

# Generating the zero-trust OIDC Federated Credential for the production environment
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{"name":"github-actions-environment-production","issuer":"https://token.actions.githubusercontent.com","subject":"repo:aintnier/azure-hub-spoke-terraform:environment:production","audiences":["api://AzureADTokenExchange"]}'
```

![App Registration](docs/imgs/setup/01-app-registration-overview.png)
<br>
![OIDC Federated Credentials](docs/imgs/setup/02-federated-credentials.png)

### 2. Centralized Terraform State
A strictly isolated Azure Storage Account (`tsterraformstate26032026`) tracks the state for all 3 networking layers independently via separate Blob Containers: `layer1-manual-peering`, `layer2-avnm`, and `layer3-vwan`.

```bash
# Provisioning the dedicated Storage Account and Containers
az group create --name rg-terraform-state --location westeurope

az storage account create \
  --name tsterraformstate26032026 \
  --resource-group rg-terraform-state \
  --location westeurope \
  --sku Standard_LRS

az storage container create --name layer1-manual-peering --account-name tsterraformstate26032026
az storage container create --name layer2-avnm --account-name tsterraformstate26032026
az storage container create --name layer3-vwan --account-name tsterraformstate26032026
```

![Storage Containers](docs/imgs/setup/06-storage-containers.png)

### 3. Continuous Integration (CI)
The project enforces strict code quality through a GitHub Actions matrix workflow ([`ci.yml`](.github/workflows/ci.yml)). On every push to `main` (or PR), it automatically runs `terraform fmt`, `init`, and `validate` across all three architecture layers in parallel—without needing to contact Azure State.

![CI Success](docs/imgs/setup/08-github-actions-ci-success.png)
<br>
![Terraform Validate Logs](docs/imgs/setup/09-github-actions-tf-validate-logs.png)

---

## Quick Start

### Prerequisites

- Azure Subscription with Contributor access
- [Terraform](https://www.terraform.io/downloads) >= 1.5
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50
- SSH key pair (`~/.ssh/id_rsa.pub`)

### Deploy a Layer

```bash
cd layer1-manual-peering
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# When done testing:
terraform destroy -auto-approve
```

### CI/CD via GitHub Actions

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push / PR to `main` | Format check, validate, plan |
| `deploy-layerN.yml` | Manual | `terraform apply` |
| `destroy-layerN.yml` | Manual | `terraform destroy` |

Authentication uses **OIDC** (Federated Identity Credential) - no long-lived secrets.

---

## Repository Structure

```
├── .github/workflows/        # CI/CD pipelines (7 workflows)
├── layer1-manual-peering/    # VNet Peering + Firewall + UDR + VMs
├── layer2-avnm/              # AVNM dynamic groups + Firewall + VMs
├── layer3-vwan/              # Virtual WAN + Secured Hub + VMs
└── README.md                 # This file
```

Each layer contains a `RUNBOOK.md` documenting deployment sessions, connectivity tests, firewall logs, and lessons learned.

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| IaC | Terraform >= 1.5, AzureRM ~> 3.x |
| CI/CD | GitHub Actions |
| Cloud | Microsoft Azure |
| Auth | OIDC (Federated Identity Credential) |
| Test VMs | Ubuntu 22.04 LTS (Standard_B1s) |

---

## License

MIT
