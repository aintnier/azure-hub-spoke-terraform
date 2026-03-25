# Azure Hub-and-Spoke Networking — Terraform Portfolio

[![Terraform CI](https://github.com/aintnier/azure-hub-spoke-terraform/actions/workflows/ci.yml/badge.svg)](https://github.com/aintnier/azure-hub-spoke-terraform/actions/workflows/ci.yml)

A professional portfolio project demonstrating the evolution of **Hub-and-Spoke network topologies** on Microsoft Azure — from manual VNet Peering to policy-driven automation with AVNM to fully managed SD-WAN with Virtual WAN.

All infrastructure is provisioned via **Terraform**, automated through **GitHub Actions CI/CD**, and designed to be **ephemeral** (~€5 per test session).

---

## Architecture — 3 Progressive Layers

| Layer | Technology | Key Concept |
|-------|-----------|------------|
| [Layer 1](layer1-manual-peering/) | Manual VNet Peering | Traditional approach, full control |
| [Layer 2](layer2-avnm/) | Azure Virtual Network Manager | Tag-based dynamic membership |
| [Layer 3](layer3-vwan/) | Azure Virtual WAN | Fully managed hub, Routing Intent |

All layers share the same logical pattern: spoke-to-spoke traffic is routed through a central **Azure Firewall (Standard)** acting as the NVA.

```
         Spoke 1 ──── peering/connection ───── Hub (Firewall) ───── peering/connection ──── Spoke 2
           VM                                     │                                          VM
                                              UDR / Routing Intent
                                          forces all traffic through FW
```

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

Authentication uses **OIDC** (Federated Identity Credential) — no long-lived secrets.

---

## Repository Structure

```
├── .github/workflows/       # CI/CD pipelines (7 workflows)
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
