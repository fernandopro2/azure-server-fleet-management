# Azure Server Fleet Management & Observability

## 1. Purpose

Azure Server Fleet Management & Observability is a Terraform-based project for deploying and operating a small Windows and Linux virtual machine fleet in Microsoft Azure. The development environment combines secure administrative connectivity, centralized monitoring, alerting, and scheduled operating system patch management.

The documented implementation is a development environment in **Canada Central**. It is intentionally cost-conscious and does not implement high availability or disaster recovery.

## 2. Architecture Principles

The project uses the Microsoft Azure Well-Architected Framework as its architectural reference:

- **Reliability:** provide operational visibility and scheduled maintenance for the virtual machines. High availability and disaster recovery are outside the current development scope.
- **Security:** avoid public IP addresses on workload VMs, provide administrative access through Azure Bastion, use Key Vault as the source of local administrator credentials, and apply network restrictions.
- **Cost Optimization:** use development-sized virtual machines, a 30-day Log Analytics retention period, and Azure-native management services.
- **Operational Excellence:** provision infrastructure through reusable Terraform modules and keep implementation decisions in version control.
- **Performance Efficiency:** collect operating-system performance counters and use Azure Monitor alerts to identify selected operational conditions.

These principles guide the implementation; they do not imply that every Well-Architected capability has been implemented.

## 3. Environment

| Property | Value |
|---|---|
| Environment | `dev` |
| Azure region | `canadacentral` (Canada Central) |
| Project identifier | `srvfleet` |
| Virtual network address space | `10.10.0.0/16` |
| Workload subnet | `10.10.0.0/24` |
| Azure Bastion subnet | `10.10.1.0/26` |
| Log Analytics retention | 30 days |
| Infrastructure as Code | Terraform |
| AzureRM provider constraint | `~> 5.0` |
| Random provider constraint | `~> 3.0` |

Resource names are generated using Terraform locals and random suffixes. The exact resource names therefore depend on the generated values for a deployment and should not be treated as fixed identifiers in this document.

## 4. Azure Infrastructure Components

### 4.1 Resource organization and naming

The root Terraform configuration creates a resource group. Naming locals use the project, environment, a short region code (`cac` for Canada Central), and a random numeric suffix. VM-related names also include a random identifier.

The environment tag is created as `Env = DEV`. This tag is also used by the Update Manager dynamic scope.

### 4.2 Networking

The networking module provisions:

- Azure Virtual Network with address space `10.10.0.0/16`.
- Workload subnet `10.10.0.0/24`.
- Network Security Group associated with the workload subnet.
- Inbound RDP (`3389/TCP`) and SSH (`22/TCP`) rules whose source is the Bastion subnet prefix `10.10.1.0/26`.

The dedicated `AzureBastionSubnet` is created by the Bastion module. See [NETWORK_DESIGN.md](NETWORK_DESIGN.md).

### 4.3 Compute

The initial fleet contains two VMs:

| Workload | Operating system | Size | OS disk storage type |
|---|---|---|---|
| Windows | Windows Server 2022 Datacenter | `Standard_B2s` | `Standard_LRS` |
| Linux | Ubuntu Server 22.04 LTS | `Standard_B2s` | `Standard_LRS` |

Both VMs use private network interfaces and System Assigned Managed Identities. The submitted Terraform configuration does not assign public IP addresses to the VMs.

The VM module retrieves the local administrator passwords from Azure Key Vault data sources. The current access procedure uses local credentials. Microsoft Entra ID login extensions are also deployed on both operating systems, preserving an option for a future change in access method; their presence does not mean that Entra ID is the current interactive authentication method.

### 4.4 Azure Bastion

Azure Bastion is deployed using the **Basic** SKU. Its module creates a dedicated public IP address and the `AzureBastionSubnet`. Administrators connect to the private VMs through Bastion rather than assigning public IP addresses directly to the VMs.

The Bastion module receives the existing VNet name from the networking module through its `vnet_name` output.

### 4.5 Monitoring and observability

Azure Monitor and Log Analytics provide centralized monitoring.

Implemented components:

- Log Analytics Workspace with 30-day retention.
- Azure Monitor Agent (AMA) extensions on Windows and Linux.
- Separate Windows and Linux Data Collection Rules (DCRs).
- DCR associations for the VMs.
- CPU and Heartbeat alerting.

See [MONITORING_DESIGN.md](MONITORING_DESIGN.md).

### 4.6 Update management

Azure Update Manager manages operating-system update assessment and scheduled patch installation.

The current configuration uses:

- Platform-managed periodic assessment.
- Customer-managed patch schedules through `InGuestPatch`.
- A weekly maintenance window on Tuesday at 14:00 Quebec local time.
- A three-hour duration.
- Reboot when required.
- A dynamic scope that selects virtual machines with the tag `Env = DEV`.

The maintenance window values are supplied through the Terraform maintenance configuration variable. See [UPDATE_MANAGEMENT.md](UPDATE_MANAGEMENT.md).

## 5. Logical Architecture

The solution is organized into the following layers:

1. **Foundation**
   - Resource group
   - Resource naming and tags
   - Terraform environment configuration

2. **Network and access**
   - Virtual network and workload subnet
   - Network Security Group
   - Azure Bastion and its public IP

3. **Compute**
   - Windows Server 2022 VM
   - Ubuntu Server 22.04 VM
   - Managed OS disks
   - System Assigned Managed Identities
   - VM extensions for AMA and Entra ID login

4. **Monitoring**
   - Log Analytics Workspace
   - Azure Monitor Agent
   - Windows and Linux DCRs
   - DCR associations
   - CPU and Heartbeat alerts

5. **Operations**
   - Azure Update Manager
   - Periodic update assessment
   - Maintenance Configuration
   - Dynamic Scope assignment

## 6. Terraform Architecture

The root environment is located at `terraform/environments/dev/` and consumes reusable modules under `terraform/modules/`.

The modules represented in the supplied project files are:

- `networking`
- `virtual-machine`
- `bastion`
- `log-analytics`
- `azure-monitor`
- `update-manager`

Environment-specific values, including VM sizing, monitoring collection settings, and maintenance-window settings, are supplied through Terraform variables and the development variable file.

The submitted provider configuration declares:

- `hashicorp/azurerm` with constraint `~> 5.0`
- `hashicorp/random` with constraint `~> 3.0`

Terraform state, backend configuration, CI/CD configuration, and repository branch protection are not established by the files reviewed for this document and are not described as implemented here.

## 7. Security Boundaries and Current Limitations

Implemented controls evidenced by the submitted Terraform:

- No public IP is assigned to either workload VM.
- Administrative connectivity is provided through Azure Bastion.
- The workload subnet NSG includes inbound RDP and SSH rules sourced from the Bastion subnet.
- Local administrator passwords are read from Azure Key Vault.
- VM System Assigned Managed Identities are enabled.
- Azure Monitor Agent and Entra ID login extensions are provisioned.

Current operational detail:

- Local credentials are used for VM access at present.
- Entra ID login extensions are deployed, but Entra ID authentication is not the current access method.
- Azure Policy is not implemented. It remains a planned governance enhancement.
- Alert notification delivery (for example, email or SMS through an Action Group) is not part of the current implementation.

The submitted code should be reviewed separately for secret-reference hygiene and least-privilege access to Key Vault and Azure resources. This document does not claim that those access permissions have been independently audited.

## 8. Implementation and Validation Status

The following status reflects the implementation and validation information provided for this documentation update:

| Capability | Status |
|---|---|
| Resource group, VNet, workload subnet and NSG | Deployed |
| Windows and Linux VMs | Deployed |
| Azure Bastion Basic | Deployed and tested |
| Log Analytics Workspace | Deployed |
| AMA and DCR configuration | Deployed and validated |
| CPU alert | Deployed and functionally tested |
| Heartbeat alert | Deployed and functionally tested, including Fired and Resolved transitions |
| Periodic update assessment | Enabled and working on both VMs |
| Maintenance Configuration and dynamic scope | Deployed |
| Patch installation | Executed and tested |
| Azure Policy | Planned; not implemented |
| Alert notification delivery | Not implemented |
| CI/CD automation | Not confirmed by the reviewed files |

## 9. Future Evolution

Potential future work, not represented as implemented:

- Azure Policy assignments for audit and governance.
- Alert notification delivery using Action Groups.
- Terraform CI/CD and automated quality/security checks.
- Expanded security-event collection and security monitoring.
- Additional workloads and environments.
- Operational runbooks and formal acceptance criteria.

Architectural changes should be recorded in [DECISIONS.md](DECISIONS.md) and reflected in the relevant design documents.
