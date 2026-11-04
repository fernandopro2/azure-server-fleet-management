# Azure Server Fleet Management & Observability

## 1. Architecture Overview

The Azure Server Fleet Management & Observability project provides a centralized solution for deploying, managing, monitoring, and maintaining Windows and Linux virtual machines hosted in Microsoft Azure.

The infrastructure is provisioned and managed using Terraform. Azure native services are used for secure connectivity, monitoring, logging, alerting, and update management.

The initial implementation targets a development environment in Canada Central.

## 2. Architecture Principles

The solution follows the Microsoft Azure Well-Architected Framework principles:

- **Reliability:** Deploy a functional infrastructure baseline with clearly defined operational boundaries.
- **Security:** Apply least privilege, secure administrative access, and avoid direct public exposure of virtual machines.
- **Cost Optimization:** Use cost-conscious Azure SKUs suitable for a development environment.
- **Operational Excellence:** Automate infrastructure provisioning and maintain infrastructure as code.
- **Performance Efficiency:** Collect infrastructure metrics and monitor resource utilization.

High availability and disaster recovery are outside the scope of the initial development environment.

## 3. Azure Infrastructure Components

### 3.1 Networking

The networking layer provides secure connectivity between infrastructure components.

Components:

- Azure Virtual Network
- Workload subnet
- Azure Bastion subnet
- Network Security Group

Virtual machines will not have public IP addresses.

Administrative access will be provided through Azure Bastion.

### 3.2 Virtual Machines

The initial fleet consists of two virtual machines:

| Resource | Operating System | VM Size |
|---|---|---|
| vm-srvfleet-dev-001 | Windows Server 2022 Datacenter | Standard_B2s |
| vm-srvfleet-dev-002 | Ubuntu Server 24.04 LTS | Standard_B2s |

Both virtual machines will use managed disks.

The Windows virtual machine will use a protected local administrator password.

The Linux virtual machine will use SSH key authentication.

### 3.3 Azure Bastion

Azure Bastion provides secure administrative connectivity to the virtual machines.

The service will be deployed using the Basic SKU.

RDP and SSH connectivity will be provided through Azure Bastion without exposing the virtual machines directly to the Internet.

### 3.4 Monitoring and Observability

Azure Monitor and Log Analytics provide centralized infrastructure monitoring.

Components:

- Log Analytics Workspace
- Azure Monitor Agent (AMA)
- Data Collection Rules (DCR)
- Azure Monitor Alerts

The monitoring solution will collect:

- CPU utilization
- Memory utilization
- Disk utilization
- VM heartbeat
- Windows System and Application event logs
- Linux syslog events

The initial Log Analytics retention period will be 30 days.

### 3.5 Update Management

Azure Update Manager will be used to assess and manage operating system updates.

The initial configuration includes:

- Daily update assessment
- Weekly maintenance schedule
- Saturday maintenance window at 02:00 Quebec local time
- Two-hour maintenance duration
- Reboot allowed

## 4. Logical Architecture

The solution is organized into the following logical layers:

1. **Infrastructure Layer**
   - Resource Group
   - Virtual Network
   - Subnets
   - Network Security Group

2. **Compute Layer**
   - Windows Virtual Machine
   - Linux Virtual Machine
   - Managed Disks

3. **Administrative Access Layer**
   - Azure Bastion
   - Secure RDP and SSH access

4. **Monitoring Layer**
   - Azure Monitor Agent
   - Data Collection Rules
   - Log Analytics Workspace
   - Alert Rules

5. **Operations Layer**
   - Azure Update Manager
   - Update assessment
   - Scheduled maintenance

## 5. Terraform Architecture

Terraform is responsible for provisioning and managing the Azure infrastructure.

The repository will use a modular structure:

- `terraform/environments/dev/`
- `terraform/modules/networking/`
- `terraform/modules/virtual-machine/`
- `terraform/modules/bastion/`
- `terraform/modules/log-analytics/`
- `terraform/modules/azure-monitor/`
- `terraform/modules/update-manager/`

The development environment will consume reusable Terraform modules.

Infrastructure changes will be version-controlled through Git.

Terraform state and sensitive configuration files must not be committed to the repository.

## 6. Security Considerations

The initial architecture follows these security principles:

- No public IP addresses assigned to virtual machines.
- Administrative access through Azure Bastion.
- SSH key authentication for Linux.
- Protected administrator credentials for Windows.
- Network Security Group rules based on least privilege.
- Secrets must not be stored in Git.
- Terraform state must be protected.
- Azure resources must use appropriate access controls.

## 7. Initial Environment

| Property | Value |
|---|---|
| Environment | dev |
| Azure Region | Canada Central |
| Resource Group | rg-srvfleet-dev-canadacentral-001 |
| Virtual Network | vnet-srvfleet-canadacentral-001 |
| Log Analytics Workspace | law-srvfleet-dev-canadacentral-001 |
| Infrastructure as Code | Terraform |

## 8. Future Evolution

The architecture may evolve to include:

- Additional virtual machines
- Automated deployment pipelines
- Advanced monitoring and alerting
- Cost analysis and optimization
- Infrastructure compliance validation
- Additional Azure management capabilities

Any architectural evolution must be documented and validated against the Azure Well-Architected Framework.