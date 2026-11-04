# Azure Server Fleet Management & Observability

## 1. Network Overview

The network architecture provides secure connectivity for the Azure Server Fleet Management & Observability development environment.

The infrastructure is deployed in the Canada Central Azure region.

The network design follows a defense-in-depth approach, using network segmentation, Network Security Groups (NSGs), and Azure Bastion to protect administrative access to virtual machines.

Virtual machines will not be directly exposed to the Internet through public IP addresses.

## 2. Virtual Network

The solution uses a dedicated Azure Virtual Network.

| Property | Value |
|---|---|
| Name | vnet-srvfleet-canadacentral-001 |
| Address Space | 10.10.0.0/16 |
| Azure Region | Canada Central |
| Resource Group | rg-srvfleet-dev-canadacentral-001 |

The virtual network provides private IP connectivity between infrastructure components.

## 3. Subnet Design

The virtual network contains two subnets.

| Subnet | Name | Address Prefix | Purpose |
|---|---|---|---|
| Workload Subnet | snet-srvfleet-canadacentral-001 | 10.10.1.0/24 | Hosts Windows and Linux virtual machines |
| Azure Bastion Subnet | AzureBastionSubnet | 10.10.2.0/26 | Hosts Azure Bastion |

The Azure Bastion subnet uses the mandatory subnet name `AzureBastionSubnet`.

The subnet is dedicated to the Azure Bastion service.

## 4. Network Security Group

A Network Security Group will be associated with the workload subnet.

| Property | Value |
|---|---|
| Name | nsg-srvfleet-dev-001 |
| Scope | Workload Subnet |
| Purpose | Control inbound and outbound network traffic |

The NSG will enforce least-privilege network access.

Administrative access to the virtual machines will be provided through Azure Bastion.

Detailed NSG rules will be defined and validated during the Terraform networking module implementation.

## 5. Azure Bastion

Azure Bastion provides secure administrative access to the virtual machines.

| Property | Value |
|---|---|
| Name | bas-srvfleet-dev-canadacentral-001 |
| SKU | Basic |
| Subnet | AzureBastionSubnet |
| Public IP | Required for Azure Bastion |

Azure Bastion enables administrators to connect to the virtual machines using RDP or SSH without assigning public IP addresses to the virtual machines.

The Azure Bastion public IP address is distinct from the private IP addresses assigned to the virtual machines.

## 6. Virtual Machine Network Connectivity

The Windows and Linux virtual machines will be deployed in the workload subnet.

| Virtual Machine | Operating System | Network Placement |
|---|---|---|
| vm-srvfleet-dev-001 | Windows Server 2022 Datacenter | Workload Subnet |
| vm-srvfleet-dev-002 | Ubuntu Server 24.04 LTS | Workload Subnet |

Both virtual machines will use private IP addresses.

No public IP addresses will be assigned directly to the virtual machines.

## 7. Logical Network Diagram

The network topology is represented as follows:

Internet
   |
   | HTTPS
   |
Azure Bastion Public IP
   |
Azure Bastion
   |
   | RDP / SSH
   |
Virtual Network: 10.10.0.0/16
   |
   +-- Workload Subnet: 10.10.1.0/24
   |      |
   |      +-- Windows VM: vm-srvfleet-dev-001
   |      |
   |      +-- Linux VM: vm-srvfleet-dev-002
   |      |
   |      +-- NSG: nsg-srvfleet-dev-001
   |
   +-- AzureBastionSubnet: 10.10.2.0/26
          |
          +-- Azure Bastion: bas-srvfleet-dev-canadacentral-001

## 8. Network Security Principles

The network