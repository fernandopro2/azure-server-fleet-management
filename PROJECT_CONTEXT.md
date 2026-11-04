
# Azure Server Fleet Management & Observability
## Project Context and Working Agreement

## 1. Project Overview

**Project name:** Azure Server Fleet Management & Observability  
**Repository:** `azure-server-fleet-management`  
**Project type:** Azure Cloud Engineering portfolio project  
**Environment:** `dev`  
**Infrastructure as Code:** Terraform  
**State management:** HCP Terraform

### Purpose

Implement an Azure-based server fleet management and observability solution using Terraform, Azure Monitor, and Azure Update Manager.

The project demonstrates the operational lifecycle of Azure infrastructure, including provisioning, secure administration, monitoring, update management, validation, and documentation.

The initial lab consists of one Windows Server virtual machine and one Linux virtual machine.

## 2. Mandatory Engineering Standard

The Microsoft Azure Well-Architected Framework (WAF) is mandatory throughout the project.

Its five pillars must be considered continuously:

- **Reliability:** Availability, recovery, resilience, and failure handling.
- **Security:** Identity, least privilege, network controls, secrets, and secure configuration.
- **Cost Optimization:** Appropriate sizing, architectural cost awareness, resource lifecycle, and avoiding unnecessary services.
- **Operational Excellence:** Infrastructure as Code, repeatable deployments, monitoring, automation, documentation, and continuous improvement.
- **Performance Efficiency:** Appropriate resource sizing, efficient monitoring, and resource utilization.

For every significant decision:
- Explain the objective and rationale.
- Identify relevant WAF considerations and trade-offs.
- Validate Azure service behavior against current Microsoft documentation when necessary.
- Avoid unnecessary complexity.
- Clearly distinguish planned, implemented, and validated functionality.

Azure Verified Modules (AVMs) should be considered where appropriate.

## 3. Approved Architecture Decisions

The following decisions were approved during Phase 0.

### 3.1 Azure Environment

| Item | Approved decision |
|---|---|
| Subscription | Azure Pay-As-You-Go |
| Region | Canada Central |
| Environment | Development (`dev`) |
| Resource Group | `rg-srvfleet-dev-canadacentral-001` |
| Deployment approach | Terraform CLI initially |
| State management | HCP Terraform |
| HCP Terraform organization | `fernandosantos-org` |
| HCP Terraform workspace | `azure-server-fleet-management-dev` |
| Source control | Private GitHub repository |

The HCP Terraform workspace is planned and must be created and validated before remote state is configured.

The user manages Azure budgets and financial cost controls separately. Architectural cost optimization remains a project requirement.

### 3.2 Virtual Network

| Resource | Name | Configuration |
|---|---|---|
| Virtual Network | `vnet-srvfleet-canadacentral-001` | `10.10.0.0/16` |
| Workload subnet | `snet-srvfleet-canadacentral-001` | `10.10.1.0/24` |
| Bastion subnet | `AzureBastionSubnet` | `10.10.2.0/26` |
| Network Security Group | `nsg-srvfleet-dev-001` | Workload network controls |

No public IP addresses will be assigned to the virtual machines.

Azure Bastion will provide administrative access.

No VNet peering is planned for the initial implementation.

### 3.3 Azure Bastion

| Item | Approved decision |
|---|---|
| SKU | Basic |
| Resource name | `bas-srvfleet-dev-canadacentral-001` |
| Administrative access | RDP and SSH through Bastion |
| VM public IP | Not permitted |

Validate current Azure Bastion SKU capabilities and requirements before implementation.

### 3.4 Virtual Machines

| Item | Windows VM | Linux VM |
|---|---|---|
| Resource name | `vm-srvfleet-dev-001` | `vm-srvfleet-dev-002` |
| Operating system | Windows Server 2022 Datacenter | Ubuntu Server 24.04 LTS |
| VM size | Standard_B2s | Standard_B2s |
| Disk | 128 GiB Standard SSD | 64 GiB Standard SSD |
| Public IP | None | None |
| Administration | RDP through Bastion | SSH through Bastion |

Linux authentication will use an SSH key pair.

Windows authentication will use a protected local administrator password.

Credentials and private keys must never be committed to Git.

### 3.5 Resource Tags

The following tags are approved:

| Tag | Value |
|---|---|
| `project` | `azure-server-fleet-management` |
| `environment` | `dev` |
| `workload` | `srvfleet` |
| `region` | `canadacentral` |
| `managedBy` | `terraform` |

### 3.6 Log Analytics and Azure Monitor

| Item | Approved decision |
|---|---|
| Log Analytics Workspace | `law-srvfleet-dev-canadacentral-001` |
| Retention | 30 days |
| Azure Monitor Agent | Planned where required |
| Data Collection Rules | Planned |
| Monitoring scope | VM health, metrics, and selected logs |

Initial monitoring scope:

- VM heartbeat.
- CPU metrics.
- Memory metrics.
- Disk metrics.
- Windows System event log.
- Windows Application event log.
- Ubuntu syslog.

Windows Security Event Log collection is excluded initially.

Azure Update Manager is complementary to Azure Monitor. Its core update-management functionality must not be assumed to require AMA or Log Analytics Workspace. Validate the requirements of each feature before implementation.

### 3.7 Alerts

The initial alert requirements are:

| Alert | Condition |
|---|---|
| VM heartbeat | Missing for 5 minutes |
| CPU utilization | Above 80% for 15 minutes |

Email and SMS notifications are excluded initially.

Alert configuration and end-to-end testing remain pending.

### 3.8 Azure Update Manager

Approved configuration:

| Item | Decision |
|---|---|
| Assessment | Daily |
| Patch installation | Weekly |
| Maintenance day | Saturday |
| Maintenance time | 02:00 Québec local time |
| Maintenance duration | 2 hours |
| Reboot | Permitted |

The implementation must validate supported schedules, timezone behavior, operating system configuration, and current Azure Update Manager capabilities.

Updates must be applied through a controlled maintenance process.

### 3.9 Terraform Authentication and State

Terraform will use the existing Azure Service Principal.

HCP Terraform workspace environment variables:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET` — sensitive
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

The Azure Service Principal and its RBAC permissions must be validated before deployment.

Do not replace this authentication approach with an `az login` workflow unless explicitly approved.

Terraform state must be stored remotely and protected.

Never commit state files, credentials, private keys, or sensitive variable files.

## 4. Repository Structure

Approved initial structure:

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

The structure may evolve when implementation requirements are validated.

## 5. Git and Repository Workflow

Repository: `azure-server-fleet-management`

Visibility: Private

Approved branch strategy:

- `main`: stable and validated project state.
- `develop`: integration branch.
- `feature/<name>`: individual implementation tasks.

GitHub VCS-driven Terraform workflow will be introduced later.

Initially, Terraform CLI will be used.

Commit conventions:
- Small, descriptive commits.
- English commit messages.
- Commit only validated changes where appropriate.
- Do not commit secrets or Terraform state.

## 6. Validation Tooling

The following tools are approved:

- `terraform fmt`
- `terraform validate`
- TFLint
- Checkov

Initially, these validations will be executed locally.

GitHub Actions will be introduced in a later phase.

## 7. Documentation Deliverables

Maintain the following documents:

- `README.md`: Project overview, architecture, technology stack, and status.
- `PROJECT_CONTEXT.md`: Authoritative project context and working agreement.
- `docs/ARCHITECTURE.md`: Architecture and component responsibilities.
- `docs/NETWORK_DESIGN.md`: Network topology and security boundaries.
- `docs/MONITORING_DESIGN.md`: Monitoring, collection, metrics, and alerts.
- `docs/UPDATE_MANAGEMENT.md`: Update strategy and maintenance configuration.
- `docs/DECISIONS.md`: Architectural decisions and their status.

Documentation must distinguish between planned, implemented, and validated functionality.

## 8. Project Phases

| Phase | Description | Status |
|---|---|---|
| Phase 0 | Discovery and architecture design | Completed |
| Phase 1 | Repository and local development setup | In progress |
| Phase 2 | Terraform foundation and HCP Terraform remote state | Planned |
| Phase 3 | Networking and Azure Bastion | Planned |
| Phase 4 | Virtual machine provisioning | Planned |
| Phase 5 | Azure Monitor and observability | Planned |
| Phase 6 | Azure Update Manager | Planned |
| Phase 7 | Validation, security checks, and automation | Planned |

Phase boundaries may be adjusted based on verified prerequisites.

## 9. Definition of Success

The project is successful when:

- Infrastructure can be deployed reproducibly with Terraform.
- Terraform code is modular, validated, and source-controlled.
- Windows and Linux VMs are securely accessible through Azure Bastion.
- Monitoring data is collected and can be investigated.
- At least one alert is tested end to end.
- Azure Update Manager assessment and controlled patching are demonstrated.
- Post-update validation and compliance can be explained with evidence.
- Documentation is sufficient for another engineer to reproduce the lab.
- WAF trade-offs can be explained confidently in a Cloud Engineer interview.

## 10. Working Agreement

When assisting with this project:

1. Use Portuguese for conversation unless another language is requested.
2. Provide step-by-step micro-instructions.
3. Explain the objective and context before commands or code.
4. Pause for confirmation after meaningful steps.
5. Provide complete file contents when a file is created or updated.
6. Keep documentation and code comments in English.
7. Follow Git discipline.
8. Validate actual outputs; never assume success.
9. Diagnose failed validation before proceeding.
10. Avoid unnecessary complexity or scope changes.
11. Consider Azure costs and WAF implications at every deployment step.
12. Verify current Microsoft documentation when Azure behavior or provider syntax may have changed.
13. Maintain project continuity by updating this document when approved decisions change.
14. Mark decisions as proposed, accepted, implemented, or validated.

## 11. Current Project State

### Completed

- Phase 0 architecture and design decisions approved.
- Private GitHub repository created.
- Local repository cloned.
- `main` branch established.
- Initial directory structure created.
- `.gitignore` created and validated.
- `README.md` created and validated.

### Pending

- Create and validate this `PROJECT_CONTEXT.md`.
- Create architecture and design documentation.
- Establish Git commits and integration branch.
- Configure HCP Terraform workspace.
- Configure and validate remote state.
- Implement Terraform foundation.

No Azure infrastructure has been provisioned as part of the project implementation at this point.
