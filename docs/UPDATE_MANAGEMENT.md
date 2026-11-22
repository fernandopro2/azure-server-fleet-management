# Azure Server Fleet Management & Observability

## 1. Update Management Overview

Azure Update Manager is used to assess and manage operating-system updates for the Windows Server 2022 and Ubuntu Server 22.04 virtual machines in the development environment.

The implementation separates periodic update assessment from the customer-managed patch installation schedule.

## 2. Selected Management Approach

The project uses Azure Update Manager with a customer-managed maintenance schedule (`InGuestPatch`).

The VM resources are configured with:

| VM setting | Value |
|---|---|
| `patch_assessment_mode` | `AutomaticByPlatform` |
| `patch_mode` | `AutomaticByPlatform` |
| `bypass_platform_safety_checks_on_user_schedule_enabled` | `true` |

The Maintenance Configuration uses:

| Setting | Value |
|---|---|
| `scope` | `InGuestPatch` |
| `in_guest_user_patch_mode` | `User` |
| Reboot behavior | `IfRequired` |

This is the selected Azure Update Manager scheduled-patching approach. It should not be described as the separate Automatic VM Guest Patching approach.

## 3. Managed Virtual Machines

| Workload | Operating system |
|---|---|
| Windows | Windows Server 2022 Datacenter |
| Linux | Ubuntu Server 22.04 LTS |

Both VMs are included in the dynamic maintenance scope when they carry the matching environment tag.

## 4. Update Assessment

Periodic assessment is enabled through `patch_assessment_mode = "AutomaticByPlatform"` on both VM resources.

The assessment configuration is separate from the maintenance installation window. The periodic assessment setting does not, by itself, define the customer-managed installation schedule.

Assessment behavior has been confirmed as working on both VMs.

## 5. Maintenance Configuration

The Terraform Update Manager module creates an `azurerm_maintenance_configuration` resource with `scope = "InGuestPatch"` and `in_guest_user_patch_mode = "User"`.

The current maintenance settings are:

| Property | Value |
|---|---|
| Frequency | Weekly |
| Day | Tuesday |
| Start time | 14:00 |
| Time zone | `Eastern Standard Time` (Quebec local time) |
| Duration | 3 hours |
| Reboot behavior | `IfRequired` |

The schedule is supplied through the Terraform `maintenance_configuration` variable object rather than being hard-coded into the module. The current development variable values specify a start date/time of `2026-11-17 14:00`, the `Eastern Standard Time` time-zone identifier, weekly recurrence, and a duration of `03:00`.

When changing the schedule, update the external environment variable values and validate the resulting Terraform plan.

## 6. Patch Classifications

The Maintenance Configuration defines separate update classifications for each operating system.

### 6.1 Windows

The configured classifications are:

- Critical
- Security
- UpdateRollup
- Updates

### 6.2 Linux

The configured classifications are:

- Critical
- Security

The classifications are supplied through the `maintenance_configuration` variable object.

## 7. Maintenance Assignment

The implementation uses `azurerm_maintenance_assignment_dynamic_scope`.

The dynamic scope filters for:

- Resource type: `Microsoft.Compute/virtualMachines`
- Tag name: `Env`
- Tag value: `DEV`

The root Terraform configuration assigns the `Env = DEV` tag to the VM resources. Consequently, the dynamic scope selects matching development VMs without creating a separate static assignment for each VM.

The tag is therefore part of the operational maintenance boundary. New VMs carrying the same tag may be included in this maintenance scope.

## 8. Reboot Behavior

The Maintenance Configuration sets `reboot = "IfRequired"`. A VM may be restarted when the update installation requires it.

The development environment does not implement high availability, so temporary interruptions during patching are accepted.

## 9. Validation

The user confirmed that the following work was completed:

- Periodic assessment enabled and working.
- Maintenance Configuration created.
- Dynamic-scope assignment created.
- Patch installation executed and tested.

This records the reported functional validation. Detailed per-update deployment history, exact KB/package identifiers, and individual VM installation results were not included in the supplied Terraform files and are not reproduced here.

## 10. Security and Operational Considerations

- Update assessment and installation are managed through Azure-native capabilities.
- The dynamic scope relies on consistent `Env = DEV` tagging.
- The maintenance schedule is externalized through Terraform variables.
- Reboot is allowed when required.
- Azure access to manage maintenance resources should follow least privilege.
- Azure Policy is not currently implemented. It remains a planned governance enhancement and may later be used to audit configuration compliance or drift without duplicating Terraform provisioning responsibilities.

## 11. Terraform Implementation

The implementation is located in:

`terraform/modules/update-manager/`

The module creates:

- `azurerm_maintenance_configuration`
- `azurerm_maintenance_assignment_dynamic_scope`

The VM module configures the VM patch assessment and patch orchestration settings. The root environment passes the maintenance settings to the Update Manager module.
