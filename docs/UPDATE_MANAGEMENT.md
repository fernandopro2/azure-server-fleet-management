# Azure Server Fleet Management & Observability

## 1. Update Management Overview

Azure Update Manager will be used to assess, manage, and monitor operating system updates for the Azure Server Fleet Management & Observability development environment.

The solution covers the Windows Server and Ubuntu Server virtual machines.

The initial configuration establishes a recurring assessment schedule and a weekly maintenance window.

## 2. Azure Update Manager

Azure Update Manager provides centralized update management capabilities for Azure virtual machines.

The service will be used to:

- Assess available operating system updates.
- Identify missing updates.
- Schedule maintenance activities.
- Monitor update installation status.
- Manage operating system patching activities.

## 3. Managed Virtual Machines

The initial update management scope includes the following virtual machines:

| Virtual Machine | Operating System |
|---|---|
| vm-srvfleet-dev-001 | Windows Server 2022 Datacenter |
| vm-srvfleet-dev-002 | Ubuntu Server 24.04 LTS |

Both virtual machines will be included in the update assessment and maintenance configuration.

## 4. Update Assessment

Update assessment will be performed daily.

The assessment process identifies applicable updates and provides visibility into the update compliance status of the virtual machines.

The assessment schedule must be compatible with the supported capabilities of Azure Update Manager.

## 5. Maintenance Schedule

The initial maintenance configuration is defined as follows:

| Property | Value |
|---|---|
| Frequency | Weekly |
| Day | Saturday |
| Start Time | 02:00 |
| Time Zone | Quebec local time |
| Duration | 2 hours |
| Reboot Setting | Reboot allowed |

The maintenance window is intended to minimize operational disruption in the development environment.

## 6. Reboot Policy

The initial maintenance configuration allows virtual machines to reboot when required by the update installation process.

The reboot behavior must be validated during implementation to ensure compatibility with the selected Azure Update Manager configuration.

## 7. Operational Considerations

The development environment does not require high availability.

Temporary service interruptions during maintenance are acceptable.

Before introducing update management into production environments, additional requirements must be defined, including:

- Maintenance approval procedures.
- Workload availability requirements.
- Update testing procedures.
- Rollback and recovery strategy.
- Maintenance notifications.

## 8. Security Considerations

Update management contributes to the security posture of the infrastructure by helping maintain operating systems with applicable updates.

The implementation must:

- Use Azure native update management capabilities.
- Apply updates according to the defined maintenance schedule.
- Monitor update assessment and installation status.
- Maintain appropriate Azure access controls.
- Avoid storing administrative credentials in Terraform configuration or Git.

## 9. Terraform Implementation

The infrastructure supporting update management will be documented and managed through the planned Terraform module:

`terraform/modules/update-manager/`

The implementation must validate the supported Azure Update Manager capabilities and scheduling requirements.

## 10. Validation Requirements

The update management implementation must be validated against the following requirements:

- Both virtual machines are included in the update management scope.
- Daily update assessment is configured.
- Weekly maintenance is scheduled for Saturdays at 02:00 Quebec local time.
- The maintenance duration is two hours.
- Reboot is allowed.
- Update assessment and installation status can be monitored.
- The configuration is compatible with Windows Server 2022 and Ubuntu Server 24.04 LTS.