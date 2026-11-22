# Repository Structure

## 1. Purpose

This document describes the repository organization for Azure Server Fleet Management & Observability based on the Terraform files reviewed for the development environment.

The structure separates environment-specific configuration from reusable infrastructure modules and keeps architecture documentation alongside the implementation.

## 2. Repository Overview

The documented project structure is:

```text
azure-server-fleet-management/
|
+-- docs/
|   +-- ARCHITECTURE.md
|   +-- NETWORK_DESIGN.md
|   +-- MONITORING_DESIGN.md
|   +-- UPDATE_MANAGEMENT.md
|   +-- DECISIONS.md
|   +-- REPOSITORY_STRUCTURE.md
|
+-- terraform/
|   +-- environments/
|   |   +-- dev/
|   |       +-- Providers.tf
|   |       +-- Variables.tf
|   |       +-- Locals.tf
|   |       +-- Resources.tf
|   |       +-- Outputs.tf
|   |       +-- dev.tfvars
|   |
|   +-- modules/
|       +-- networking/
|       +-- virtual-machine/
|       +-- bastion/
|       +-- log-analytics/
|       +-- azure-monitor/
|       +-- update-manager/
|
+-- .gitignore
+-- README.md
+-- PROJECT_CONTEXT.md
```

The exact file names and capitalization should follow the repository as committed. The tree above reflects the organization represented by the supplied files; it does not assert that every listed root-level documentation or support file was independently inspected in this update.

## 3. Documentation Directory

| File | Responsibility |
|---|---|
| `ARCHITECTURE.md` | Overall solution architecture, components, status, and boundaries |
| `NETWORK_DESIGN.md` | VNet, subnets, NSG rules, and Bastion connectivity |
| `MONITORING_DESIGN.md` | Log Analytics, AMA, DCRs, alerts, and validation |
| `UPDATE_MANAGEMENT.md` | Assessment, maintenance schedule, patch classifications, and validation |
| `DECISIONS.md` | Architecture Decision Records |
| `REPOSITORY_STRUCTURE.md` | Repository and module organization |

Documentation should be updated alongside changes to the infrastructure and architectural decisions.

## 4. Terraform Environment

### 4.1 Development environment

Location:

`terraform/environments/dev/`

The development root configuration is responsible for:

- Declaring Terraform and provider requirements.
- Configuring the AzureRM and Random providers.
- Declaring environment variables.
- Defining naming locals and environment tags.
- Creating the resource group.
- Calling reusable modules.
- Exposing selected VM outputs.

Environment-specific values include VM definitions, monitoring settings, Log Analytics retention, network prefixes, and maintenance-window settings.

The submitted provider configuration specifies `hashicorp/azurerm` `~> 5.0` and `hashicorp/random` `~> 3.0`.

## 5. Terraform Modules

The reviewed module set is:

| Module | Responsibility |
|---|---|
| `networking/` | VNet, workload subnet, NSG, and subnet/NSG association |
| `virtual-machine/` | Network interfaces, Windows and Linux VMs, VM extensions, and VM outputs |
| `bastion/` | Bastion public IP, `AzureBastionSubnet`, and Azure Bastion host |
| `log-analytics/` | Log Analytics Workspace and retention |
| `azure-monitor/` | Windows and Linux DCRs, DCR associations, CPU alert, and Heartbeat alert resources |
| `update-manager/` | Maintenance Configuration and dynamic-scope assignment |

### 5.1 Module interfaces

The development root passes resource IDs, names, and environment-specific settings between modules.

Examples include:

- The networking module exposes the workload subnet ID and VNet name.
- The virtual-machine module exposes Windows and Linux VM objects for use by the monitoring module.
- The Log Analytics module exposes the workspace ID for monitoring resources.
- The root passes the VNet name from networking to the Bastion module.
- The root passes the maintenance configuration object to the Update Manager module.

Module outputs and input variables must remain synchronized when modules are changed.

## 6. Git Workflow

The project workflow described by the user uses:

| Branch | Purpose |
|---|---|
| `main` | Stable branch |
| `develop` | Integration branch for validated development work |
| `feature/*` | Isolated implementation work |

The user has stated that the completed infrastructure work is present in the GitHub `develop` branch. The repository itself was not accessed during this documentation update; the review was based on user-supplied files and confirmations.

Commit messages should be descriptive and written in English. Examples:

- `docs: update architecture documentation`
- `feat: implement monitoring module`
- `fix: correct bastion module interface`
- `chore: update terraform configuration`

## 7. Repository Hygiene and Security

The repository should not contain:

- Terraform state files.
- Sensitive variable files containing secrets.
- Client secrets or administrator passwords.
- Private SSH keys.
- Plan files containing sensitive values.

The reviewed VM module reads local administrator passwords from Azure Key Vault data sources. The actual secret values should not be committed to the repository.

The submitted files do not establish the configured Terraform backend or CI/CD pipeline. Those capabilities should only be documented as implemented after their configuration is reviewed.

## 8. Engineering Principles

- Keep environment-specific configuration separate from reusable modules.
- Maintain clear module responsibilities and interfaces.
- Validate Terraform changes before deployment.
- Keep code and documentation aligned.
- Consider security and cost throughout implementation.
- Record material architecture decisions in `DECISIONS.md`.
- Do not treat planned work as completed implementation.

## 9. Future Evolution

Potential repository improvements include:

- Additional environment roots.
- Terraform CI/CD workflows.
- Formatting, validation, linting, and security scanning automation.
- Automated testing and drift review.
- Operational runbooks and acceptance documentation.

These items remain future work unless separately implemented and validated.
