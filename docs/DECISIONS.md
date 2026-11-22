# Architecture Decision Records

## 1. Purpose

This document records architectural decisions for Azure Server Fleet Management & Observability. It preserves the rationale and consequences of decisions that affect the project structure and operations.

A decision is not treated as implemented merely because it is listed here. Implementation status is described where relevant.

## 2. Decision Records

### ADR-001: Use Terraform for Infrastructure as Code

**Status:** Accepted

**Context:**

The project requires repeatable and maintainable Azure infrastructure provisioning.

**Decision:**

Terraform is used to provision and manage the Azure resources in the development environment.

**Consequences:**

- Infrastructure configuration is maintained as code.
- Reusable modules separate environment composition from resource implementation.
- Infrastructure changes are intended to follow Git-based workflows.
- Terraform state and credentials require appropriate protection.

### ADR-002: Deploy the Initial Environment in Canada Central

**Status:** Accepted

**Context:**

The development environment requires a defined Azure deployment region.

**Decision:**

Canada Central (`canadacentral`) is the deployment region for the initial environment.

**Consequences:**

- Azure resources are deployed in Canada Central unless a documented exception is introduced.
- Regional service availability and pricing must be considered.

### ADR-003: Avoid Public IP Addresses on Workload Virtual Machines

**Status:** Accepted

**Context:**

Administrative access to virtual machines must avoid direct exposure of VM management ports to the Internet.

**Decision:**

The Windows and Linux workload VMs do not receive public IP addresses. Azure Bastion provides the administrative access path.

**Consequences:**

- The VMs use private IP addresses.
- Azure Bastion and its public IP are part of the access architecture.
- The workload subnet NSG permits RDP and SSH from the Bastion subnet prefix.

### ADR-004: Use Azure Monitor and Log Analytics for Observability

**Status:** Accepted

**Context:**

The project requires centralized monitoring for Windows and Linux infrastructure.

**Decision:**

Use Azure Monitor Agent, Data Collection Rules, Log Analytics Workspace, and Azure Monitor alert rules.

**Consequences:**

- Windows and Linux use separate DCRs.
- DCR associations connect the rules to the corresponding VMs.
- Log Analytics retention is configured for 30 days.
- Ingestion and retention costs must be considered.
- The initial alert set includes CPU utilization and VM Heartbeat.

### ADR-005: Use Azure Update Manager with Customer-Managed Maintenance Schedules

**Status:** Accepted

**Context:**

The project requires recurring update assessment and controlled patch installation for both operating systems. The maintenance window must be defined by the project rather than left to an independent automatic guest patching schedule.

**Decision:**

Use Azure Update Manager with the `InGuestPatch` maintenance scope and user-managed patch mode. VM patch orchestration is configured for `AutomaticByPlatform`, and a Maintenance Configuration defines the customer-managed schedule.

The current schedule is weekly on Tuesday at 14:00 Quebec local time, with a three-hour duration. Reboot is allowed when required.

**Consequences:**

- Periodic assessment is enabled through the VM patch assessment configuration.
- Patch installation is governed by the Maintenance Configuration.
- Windows and Linux update classifications are configured separately.
- The maintenance schedule is supplied through Terraform variables.
- The maintenance assignment uses a dynamic scope that selects VMs with `Env = DEV`.
- Assessment and installation behavior must be validated for both operating systems.

### ADR-006: Use a Modular Terraform Repository Structure

**Status:** Accepted

**Context:**

The infrastructure should be maintainable and organized by responsibility.

**Decision:**

Separate the development environment composition from reusable Terraform modules.

**Consequences:**

- The environment root calls modules for networking, compute, Bastion, Log Analytics, Azure Monitor, and Update Manager.
- Module interfaces and outputs must remain aligned.
- Documentation must reflect the actual module boundaries.

### ADR-007: Exclude High Availability and Disaster Recovery from the Initial Development Environment

**Status:** Accepted

**Context:**

The initial environment is a development and technical-validation environment.

**Decision:**

High availability and disaster recovery are outside the initial scope.

**Consequences:**

- Temporary interruptions during maintenance are acceptable.
- The environment prioritizes cost-conscious deployment.
- Production requirements must be assessed separately.

### ADR-008: Use a Dynamic Scope for the Maintenance Assignment

**Status:** Accepted

**Context:**

The maintenance configuration should target the intended development VM fleet without requiring a separately maintained assignment for each VM.

**Decision:**

Use `azurerm_maintenance_assignment_dynamic_scope` with resource type `Microsoft.Compute/virtualMachines` and tag filter `Env = DEV`.

**Consequences:**

- VMs carrying the matching tag are selected by the maintenance dynamic scope.
- The environment tag is operationally significant and must be applied consistently.
- Adding another VM with the matching tag may bring it into the maintenance scope.

### ADR-009: Keep Azure Policy as a Future Governance Enhancement

**Status:** Accepted — Deferred

**Context:**

Terraform currently defines the infrastructure and its update-management configuration. Azure Policy could provide an additional governance and compliance layer, including auditing configuration drift.

**Decision:**

Azure Policy is not part of the current implementation. It remains a planned evolution and should not duplicate Terraform's provisioning responsibility without a defined governance requirement.

**Consequences:**

- The current deployment does not claim policy-based enforcement or compliance auditing.
- A future implementation may introduce policies in Audit mode before considering enforcement or remediation effects.
- Any policy assignment must be assessed for interaction with Terraform-managed resources.

### ADR-010: Retain Local VM Credentials as the Current Access Method

**Status:** Accepted — Current Operational Choice

**Context:**

The VM configuration includes local administrator credentials sourced from Azure Key Vault. Entra ID login extensions are also deployed, leaving room for a future authentication change.

**Decision:**

Local credentials remain the current VM access method. Entra ID login extensions are provisioned, but their presence is not treated as proof that Entra ID authentication is in operational use.

**Consequences:**

- Local credentials must remain protected in Key Vault.
- Key Vault access permissions require appropriate least privilege.
- A future move to Entra ID authentication requires an explicit implementation and validation decision.

## 3. Future Decisions

New architectural decisions should include:

- Unique identifier
- Title
- Status
- Context
- Decision
- Consequences

Accepted decisions may be superseded when justified by new requirements or technical constraints. Superseded decisions should remain in the record with their status updated.
