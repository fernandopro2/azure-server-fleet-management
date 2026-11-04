# Repository Structure

## 1. Purpose

This document defines the repository structure for the Azure Server Fleet Management & Observability project.

The repository is organized to support maintainability, modularity, infrastructure as code, documentation, and Git-based collaboration.

The structure separates environment-specific configuration from reusable Terraform modules.

## 2. Repository Overview

The repository follows the structure below:

```text
azure-server-fleet-management/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── NETWORK_DESIGN.md
│   ├── MONITORING_DESIGN.md
│   ├── UPDATE_MANAGEMENT.md
│   ├── DECISIONS.md
│   └── REPOSITORY_STRUCTURE.md
│
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │
│   └── modules/
│       ├── networking/
│       ├── virtual-machine/
│       ├── bastion/
│       ├── log-analytics/
│       ├── azure-monitor/
│       └── update-manager/
│
├── .gitignore
├── README.md
└── PROJECT_CONTEXT.md
```

## 3. Documentation Directory

The `docs/` directory contains the project's technical and architectural documentation.

| File | Responsibility |
|---|---|
| ARCHITECTURE.md | Describes the overall Azure architecture |
| NETWORK_DESIGN.md | Documents network topology and security |
| MONITORING_DESIGN.md | Defines monitoring and observability |
| UPDATE_MANAGEMENT.md | Defines operating system update management |
| DECISIONS.md | Records architectural decisions |
| REPOSITORY_STRUCTURE.md | Documents repository organization |

Documentation must be maintained as the architecture evolves.

## 4. Terraform Directory

The `terraform/` directory contains all Terraform configuration files.

It is divided into two main areas:

- `environments/`: Environment-specific Terraform configurations.
- `modules/`: Reusable Terraform modules.

## 5. Environment Configuration

### 5.1 Development Environment

Location:

`terraform/environments/dev/`

This directory contains the Terraform configuration responsible for deploying the development environment.

The environment configuration will:

- Define the Terraform provider configuration.
- Configure the Terraform backend.
- Declare required Terraform and provider versions.
- Consume reusable Terraform modules.
- Define environment-specific variables.
- Expose relevant outputs.

The development environment must not contain duplicated infrastructure logic that belongs in reusable modules.

## 6. Terraform Modules

The `terraform/modules/` directory contains reusable infrastructure modules.

### 6.1 Networking

Location:

`terraform/modules/networking/`

Responsibilities:

- Create the Azure Virtual Network.
- Create workload and Azure Bastion subnets.
- Create the Network Security Group.
- Associate the NSG with the workload subnet.

### 6.2 Virtual Machine

Location:

`terraform/modules/virtual-machine/`

Responsibilities:

- Provision Azure virtual machines.
- Configure operating system-specific settings.
- Create and associate managed disks.
- Configure network interfaces.
- Support Windows Server and Ubuntu deployments.

### 6.3 Bastion

Location:

`terraform/modules/bastion/`

Responsibilities:

- Provision Azure Bastion.
- Configure the required public IP address.
- Integrate Azure Bastion with the dedicated subnet.

### 6.4 Log Analytics

Location:

`terraform/modules/log-analytics/`

Responsibilities:

- Create the Log Analytics Workspace.
- Configure workspace retention.
- Expose workspace information required by other modules.

### 6.5 Azure Monitor

Location:

`terraform/modules/azure-monitor/`

Responsibilities:

- Configure Data Collection Rules.
- Configure monitoring resources.
- Define Azure Monitor alert rules.
- Integrate monitoring with the Log Analytics Workspace.

### 6.6 Update Manager

Location:

`terraform/modules/update-manager/`

Responsibilities:

- Configure update management resources.
- Define maintenance schedules.
- Configure update assessment.
- Support Windows and Linux virtual machines.

## 7. Git and Version Control

The repository uses the following branches:

| Branch | Purpose |
|---|---|
| main | Stable and validated code |
| develop | Development integration branch |
| feature/* | Isolated implementation work |

All infrastructure code and documentation must be version-controlled.

Commit messages must be descriptive and written in English.

Examples:

- `docs: add initial architecture documentation`
- `feat: implement networking module`
- `fix: correct subnet address configuration`
- `chore: update terraform provider version`

## 8. Security and Repository Hygiene

The repository must not contain:

- Terraform state files.
- Sensitive Terraform variable files.
- Azure client secrets.
- Administrator passwords.
- Private SSH keys.
- Terraform plan files containing sensitive information.

The `.gitignore` file must prevent sensitive and local files from being committed.

Terraform state must be stored using an appropriately secured backend.

## 9. Engineering Principles

The repository must follow these principles:

- Infrastructure must be managed using Terraform.
- Modules must have clearly defined responsibilities.
- Environment-specific configuration must remain separate from reusable modules.
- Documentation must be maintained alongside implementation.
- Infrastructure changes must be validated before deployment.
- Security and cost optimization must be considered throughout implementation.
- Architectural changes must be documented in DECISIONS.md.

## 10. Future Evolution

The repository may evolve to include:

- Additional Azure environments.
- Automated CI/CD workflows.
- Terraform testing.
- Security scanning.
- Additional infrastructure modules.

Any structural change must preserve the separation between environment configuration, reusable modules, and documentation.