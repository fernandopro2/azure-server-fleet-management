# Azure Server Fleet Management & Observability
## Project Context and Working Agreement

## 1. Project Overview

| Property | Current value |
|---|---|
| Project name | Azure Server Fleet Management & Observability |
| Repository | `azure-server-fleet-management` |
| Repository visibility | Private GitHub repository |
| Current integration branch | `develop` |
| Project type | Azure Cloud Engineering portfolio project |
| Environment | `dev` |
| Azure region | Canada Central (`canadacentral`) |
| Infrastructure as Code | Terraform |
| State management target | HCP Terraform (implementation not confirmed) |

### Purpose

Build and operate an Azure-based Windows and Linux server fleet using Terraform, Azure Monitor, and Azure Update Manager.

The project demonstrates the infrastructure lifecycle: provisioning, secure administration, monitoring, alerting, scheduled operating-system patching, validation, and technical documentation.

The current development lab contains one Windows Server virtual machine and one Ubuntu Linux virtual machine.

The documentation in this repository must describe the actual implementation and verified operational behavior. It must not preserve obsolete initial plans as if they were current configuration.

## 2. Mandatory Engineering Standard

The Microsoft Azure Well-Architected Framework (WAF) is mandatory throughout the project.

Its five pillars must be considered continuously:

- **Reliability:** availability, recovery, resilience, and failure handling.
- **Security:** identity, least privilege, network controls, secrets, and secure configuration.
- **Cost Optimization:** appropriate sizing, architectural cost awareness, resource lifecycle, and avoiding unnecessary services.
- **Operational Excellence:** Infrastructure as Code, repeatable deployments, monitoring, automation, documentation, and continuous improvement.
- **Performance Efficiency:** appropriate resource sizing, efficient monitoring, and resource utilization.

For every significant decision:

1. Explain the objective and rationale.
2. Identify relevant WAF considerations and trade-offs.
3. Validate Azure service behavior against current Microsoft documentation when necessary.
4. Avoid unnecessary complexity.
5. Clearly distinguish proposed, accepted, implemented, and validated functionality.

Azure Verified Modules (AVMs) should be considered where appropriate, but must not be introduced without evaluating fit, complexity, and project requirements.

## 3. Current Approved Architecture and Configuration

### 3.1 Azure Environment

| Item | Current value / decision |
|---|---|
| Subscription | Azure Pay-As-You-Go |
| Region | Canada Central |
| Environment | Development (`dev`) |
| Deployment | Terraform |
| Source control | Private GitHub repository |
| Current integration branch | `develop` |
| HCP Terraform organization | `fernandosantos-org` (planned context) |
| HCP Terraform workspace | `azure-server-fleet-management-dev` (planned context) |

The HCP Terraform workspace and remote-state implementation have not been confirmed as completed in the files reviewed for the current documentation update. Do not describe them as operational until their configuration and a successful run are verified.

Terraform provider constraints in the supplied configuration:

- `hashicorp/azurerm`: `~> 5.0`
- `hashicorp/random`: `~> 3.0`

Resource names are generated from Terraform locals and random suffixes. Do not treat initial example resource names as current fixed names unless verified against the active configuration or Azure deployment.

### 3.2 Network

The current development network values confirmed from the deployed `dev.tfvars` and Terraform configuration are:

| Resource | Current configuration |
|---|---|
| Virtual Network address space | `10.10.0.0/16` |
| Workload subnet | `10.10.0.0/24` |
| Azure Bastion subnet | `AzureBastionSubnet`, `10.10.1.0/26` |
| Workload NSG | Associated with the workload subnet |
| VM public IPs | None |

The workload NSG contains inbound rules for:

- RDP (`TCP/3389`) sourced from `10.10.1.0/26`.
- SSH (`TCP/22`) sourced from `10.10.1.0/26`.

Azure Bastion provides the administrative access path. No VNet peering is part of the current two-VM lab.

### 3.3 Azure Bastion

| Item | Current configuration |
|---|---|
| SKU | Basic |
| Dedicated subnet | `AzureBastionSubnet` |
| Public IP | Dedicated public IP for Bastion |
| VM public IPs | None |
| Administrative protocols | RDP and SSH through Bastion |

The Bastion module has been added to the root configuration and deployed/tested, as confirmed by the user. The root configuration consumes the VNet name exposed by the networking module.

### 3.4 Virtual Machines

| Item | Windows VM | Linux VM |
|---|---|---|
| Operating system | Windows Server 2022 Datacenter | Ubuntu Server 22.04 LTS |
| VM size | `Standard_B2s` | `Standard_B2s` |
| Public IP | None | None |
| Network | Workload subnet | Workload subnet |
| Managed identity | System Assigned | System Assigned |
| AMA extension | Windows | Linux |
| Entra ID login extension | Deployed | Deployed |
| Current interactive access method | Local credentials | Local credentials |

Local administrator credentials are retrieved from Azure Key Vault data sources in the VM module. The current operational access method uses local credentials. Entra ID login extensions are deployed to preserve flexibility for a future authentication change; their presence does not mean Entra ID is currently the interactive access method.

Do not assume that the original planned Ubuntu 24.04 version, original static VM names, or original subnet prefixes remain current.

### 3.5 Resource Tags

The environment tag used by the current Update Manager dynamic scope is:

| Tag | Value |
|---|---|
| `Env` | `DEV` |

Other tags may be defined by the Terraform configuration. Do not assume the original Phase 0 tag list is fully implemented unless confirmed by the current root configuration.

### 3.6 Log Analytics and Azure Monitor

The current monitoring implementation includes:

- Log Analytics Workspace with 30-day retention.
- Azure Monitor Agent extensions on Windows and Linux.
- Separate Windows and Linux Data Collection Rules.
- DCR associations for the corresponding VMs.
- CPU metric alert.
- Heartbeat log-to-metric conversion and metric alert.

Collection includes configured performance counters, Windows System and Application events, and Linux Syslog. Windows Security event collection is excluded from the current DCR configuration.

The CPU alert is configured for average Percentage CPU greater than 80%, with a 15-minute window and five-minute evaluation frequency.

The Heartbeat alert monitors the Heartbeat metric derived from log records, using the `Computer` dimension. The condition is a count below 5 over a five-minute window, evaluated every minute.

Functional testing was reported as completed:
- CPU alert behavior was tested.
- Both VMs were stopped to test missing Heartbeat.
- Heartbeat alert instances entered Fired.
- After the VMs were powered on and telemetry resumed, the alert instances transitioned to Resolved.

Email/SMS notification delivery through an Action Group is not implemented.

### 3.7 Azure Update Manager

The selected approach is Azure Update Manager with customer-managed maintenance scheduling (`InGuestPatch`). Do not describe this as the separate Automatic VM Guest Patching approach.

The VM resources use:

| VM setting | Value |
|---|---|
| `patch_assessment_mode` | `AutomaticByPlatform` |
| `patch_mode` | `AutomaticByPlatform` |
| `bypass_platform_safety_checks_on_user_schedule_enabled` | `true` |

The Maintenance Configuration uses:

| Setting | Value |
|---|---|
| Scope | `InGuestPatch` |
| In-guest user patch mode | `User` |
| Recurrence | Weekly |
| Day | Tuesday |
| Start time | 14:00 |
| Time zone | `Eastern Standard Time` (Québec local time) |
| Duration | 3 hours |
| Reboot behavior | `IfRequired` |

The maintenance schedule is externalized through Terraform variables. The current development variable values supplied for review specify a start of `2026-11-17 14:00`, weekly recurrence, `Eastern Standard Time`, and a three-hour duration. Future schedule changes must be made through the external variable input and validated through Terraform plan.

The maintenance assignment uses `azurerm_maintenance_assignment_dynamic_scope`, filtering `Microsoft.Compute/virtualMachines` by tag `Env = DEV`. The tag is part of the operational maintenance boundary.

Separate update classifications are configured for Windows and Linux in the maintenance configuration.

The user confirmed:
- Periodic assessment is enabled and working on both VMs.
- Maintenance Configuration was created.
- Dynamic-scope assignment was created.
- Patch installation was executed and tested.

### 3.8 Azure Policy

Azure Policy is not implemented in the current environment.

It remains a planned governance enhancement. A future implementation may begin with Audit policies to identify configuration drift or non-compliance. Policy effects such as Deny or DeployIfNotExists must not be introduced without an explicit requirement and an assessment of their interaction with Terraform.

Terraform remains responsible for provisioning and configuration. Azure Policy may provide a separate governance/compliance layer.

### 3.9 Authentication and Terraform State

The original project plan identifies an Azure Service Principal and HCP Terraform environment variables:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET` (sensitive)
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

The current provider configuration and state backend must be checked before asserting that the HCP Terraform remote-state workflow is active. Do not switch to an `az login` workflow unless explicitly approved.

Never commit credentials, private keys, sensitive variable files, Terraform state, or plan files containing sensitive information.

## 4. Current Repository Structure

The project uses a modular structure:

```text
azure-server-fleet-management/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── NETWORK_DESIGN.md
│   ├── MONITORING_DESIGN.md
│   ├── UPDATE_MANAGEMENT.md
│   ├── DECISIONS.md
│   └── REPOSITORY_STRUCTURE.md
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

The environment root composes the modules. The modules encapsulate networking, compute, Bastion, Log Analytics, Azure Monitor, and Update Manager responsibilities.

## 5. Git and Repository Workflow

Repository visibility is Private.

The user confirmed that the completed work discussed and supplied for this documentation update is in the GitHub `develop` branch.

Branch strategy:

- `main`: stable and validated project state.
- `develop`: integration branch.
- `feature/<name>`: isolated implementation tasks.

Working practices:

- Small, descriptive commits.
- English commit messages.
- Validate changes before deployment and commit.
- Do not commit secrets or Terraform state.
- Do not assume the repository has been inspected remotely. When repository access is unavailable, request the required files or command output from the user.

The GitHub repository is private. Do not claim access to its contents unless the user supplies them or explicitly establishes an authorized connection.

## 6. Validation Tooling and Engineering Workflow

Approved local validation tools:

- `terraform fmt`
- `terraform validate`
- TFLint
- Checkov

The user implements Terraform code. Provide architectural guidance, exact resource/argument guidance when requested, and review supplied code or outputs. Do not take over implementation or generate large code changes unless explicitly requested.

The working sequence is:

1. Explain the objective and relevant context.
2. Identify the exact files/resources involved.
3. Implement one manageable step.
4. Run formatting and validation.
5. Review `terraform plan`.
6. Apply only after reviewing the plan.
7. Test the deployed behavior.
8. Commit and push according to the user's Git workflow.
9. Update documentation to reflect verified results.

## 7. Documentation Deliverables

Maintain:

- `README.md`: project overview, architecture, technology stack, and current status.
- `PROJECT_CONTEXT.md`: authoritative project context and working agreement.
- `docs/ARCHITECTURE.md`: architecture and component responsibilities.
- `docs/NETWORK_DESIGN.md`: network topology and security boundaries.
- `docs/MONITORING_DESIGN.md`: monitoring, collection, metrics, and alerts.
- `docs/UPDATE_MANAGEMENT.md`: update strategy and maintenance configuration.
- `docs/DECISIONS.md`: architectural decisions and their status.
- `docs/REPOSITORY_STRUCTURE.md`: repository and module organization.

Documentation must distinguish:

- **Proposed:** under consideration, not approved.
- **Accepted:** an architectural decision has been approved.
- **Implemented:** configuration/code exists.
- **Validated:** deployed behavior has been tested and confirmed.
- **Deferred:** intentionally postponed.
- **Not implemented:** not present in the current solution.

Do not promote an item from Implemented to Validated without test evidence or user confirmation.

## 8. Project Status

| Workstream | Current status |
|---|---|
| Initial architecture and design | Completed |
| Terraform modular foundation | Implemented in `develop` |
| Networking and workload NSG | Deployed |
| Windows and Linux VMs | Deployed |
| Azure Bastion Basic | Deployed and tested |
| Log Analytics Workspace | Deployed |
| AMA and DCRs | Deployed and validated |
| CPU alert | Deployed and functionally tested |
| Heartbeat alert | Deployed and functionally tested, including Fired/Resolved |
| Periodic update assessment | Enabled and working on both VMs |
| Update Manager maintenance configuration | Deployed |
| Dynamic-scope maintenance assignment | Deployed |
| Patch installation | Executed and tested |
| Azure Policy | Deferred / planned |
| Alert Action Group notifications | Not implemented |
| HCP Terraform remote state | Not confirmed as implemented |
| CI/CD and GitHub Actions | Not confirmed as implemented |
| TFLint and Checkov automation | Not confirmed as implemented |

## 9. Next Engineering Focus

The next project work should be selected from the remaining security, governance, quality, and operational-readiness tasks. Candidate areas include:

- Review Azure RBAC assignments and least privilege.
- Review Key Vault access and secret handling.
- Review Bastion and NSG security boundaries.
- Add Azure Policy in Audit mode if a concrete governance requirement is approved.
- Introduce Terraform quality and security checks (TFLint and Checkov).
- Evaluate CI/CD and HCP Terraform remote-state integration.
- Complete operational runbooks and acceptance evidence.
- Decide whether Action Group notifications are required.

These are candidates, not claims of already scheduled or implemented work. Confirm the next work item with the user before changing scope.

## 10. Definition of Success

The project demonstrates that:

- Infrastructure can be deployed reproducibly with Terraform.
- Terraform code is modular, validated, and source-controlled.
- Windows and Linux VMs are securely accessible through Azure Bastion.
- Monitoring data is collected and can be investigated.
- CPU and Heartbeat alerts have been tested.
- Azure Update Manager assessment and scheduled patch installation have been demonstrated.
- Post-update status can be inspected and explained.
- Documentation allows another engineer to understand and reproduce the lab.
- WAF trade-offs can be explained confidently in a Cloud Engineer interview.

Additional production capabilities such as high availability, disaster recovery, policy enforcement, and automated CI/CD are outside the current demonstrated scope unless implemented later.

## 11. Working Agreement

When assisting with this project:

1. Use Portuguese for conversation unless another language is requested.
2. Provide step-by-step micro-instructions.
3. Explain the objective and context before commands or code.
4. Pause for confirmation after meaningful steps.
5. When creating or updating a file, provide its complete contents or a complete downloadable artifact.
6. Keep documentation and code comments in English.
7. Follow the user's Git discipline.
8. Validate actual outputs; never assume success.
9. Diagnose failed validation before proceeding.
10. Avoid unnecessary complexity or scope changes.
11. Consider Azure costs and WAF implications at every deployment step.
12. Verify current Microsoft documentation when Azure behavior or provider syntax may have changed.
13. Maintain project continuity by updating this document when approved decisions change.
14. Do not infer missing architectural decisions. Ask the user when source files, outputs, or prior confirmed decisions do not establish the answer.
15. Do not claim access to the private GitHub repository. Request files or command outputs when repository inspection is required.
16. The user writes the Terraform code. Do not provide large code blocks or replace implementation work unless explicitly requested.
17. Treat the supplied code, deployment outputs, and user-confirmed test results as the evidence base. Distinguish them from proposals and general recommendations.
