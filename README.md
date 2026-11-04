
# Azure Server Fleet Management & Observability

## Overview

This project implements an Azure-based server fleet management and observability solution using Terraform, Azure Monitor, and Azure Update Manager.

The solution is designed to provision, monitor, and manage a small fleet of Windows Server and Linux virtual machines while following the Microsoft Azure Well-Architected Framework.

The initial implementation focuses on a development environment (`dev`).

## Objectives

- Provision Azure infrastructure using Terraform.
- Manage Windows and Linux virtual machines.
- Provide secure administrative access through Azure Bastion.
- Monitor infrastructure health and performance using Azure Monitor.
- Centralize monitoring data in Log Analytics.
- Manage operating system updates using Azure Update Manager.
- Apply Infrastructure as Code and Git-based engineering practices.
- Implement security, reliability, operational excellence, performance efficiency, and cost optimization principles.

## Architecture

The initial architecture includes:

- Azure Resource Group
- Azure Virtual Network
- Workload subnet
- Azure Bastion subnet
- Network Security Group
- Windows Server 2022 Datacenter virtual machine
- Ubuntu Server 24.04 LTS virtual machine
- Azure Bastion Basic
- Log Analytics Workspace
- Azure Monitor Agent
- Data Collection Rules
- Azure Monitor alerts
- Azure Update Manager

Virtual machines will not have public IP addresses.

Administrative access will be provided through Azure Bastion.

## Technology Stack

| Technology | Purpose |
|---|---|
| Microsoft Azure | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| HCP Terraform | Remote state management |
| Azure Monitor | Infrastructure observability |
| Log Analytics | Monitoring data collection and analysis |
| Azure Update Manager | OS update management |
| Git | Source control |
| GitHub | Private source code repository |
| PowerShell | Windows administration and automation |

## Repository Structure

```text
azure-server-fleet-management/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── NETWORK_DESIGN.md
│   ├── MONITORING_DESIGN.md
│   ├── UPDATE_MANAGEMENT.md
│   └── DECISIONS.md
├── terraform/
│   ├── environments/
│   │   └── dev/
│   └── modules/
│       ├── networking/
│       ├── virtual-machine/
│       ├── bastion/
│       ├── log-analytics/
│       ├── azure-monitor/
│       └── update-manager/
├── .gitignore
├── README.md
└── PROJECT_CONTEXT.md
```

## Engineering Principles

- Follow the Azure Well-Architected Framework.
- Use reusable and modular Terraform configurations.
- Store Terraform state remotely in HCP Terraform.
- Never commit credentials, secrets, or Terraform state files.
- Use private networking and least-privilege access.
- Validate Terraform configurations before deployment.
- Maintain architecture and implementation documentation.
- Use Git branches and descriptive commits.

## Project Status

| Phase | Description | Status |
|---|---|---|
| Phase 0 | Architecture and design decisions | Completed |
| Phase 1 | Repository and local development setup | In progress |
| Phase 2 | Terraform foundation and remote backend | Planned |
| Phase 3 | Networking and Azure Bastion | Planned |
| Phase 4 | Virtual machine provisioning | Planned |
| Phase 5 | Monitoring and observability | Planned |
| Phase 6 | Update management | Planned |
| Phase 7 | Validation, security checks, and automation | Planned |

## Disclaimer

This project is intended for learning, engineering practice, and demonstration purposes.

All infrastructure deployments must be validated before execution.
