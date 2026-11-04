# Azure Server Fleet Management & Observability

## 1. Monitoring Overview

The monitoring architecture provides centralized observability for the Azure Server Fleet Management & Observability development environment.

Azure Monitor and Log Analytics are used to collect, analyze, and monitor infrastructure telemetry from Windows and Linux virtual machines.

The monitoring solution is designed to provide visibility into virtual machine availability, resource utilization, and operating system events.

## 2. Azure Monitor Components

The monitoring architecture includes the following components:

| Component | Purpose |
|---|---|
| Azure Monitor | Central monitoring platform |
| Log Analytics Workspace | Centralized storage and analysis of collected telemetry |
| Azure Monitor Agent (AMA) | Collects telemetry from virtual machines |
| Data Collection Rules (DCR) | Defines the telemetry collection configuration |
| Azure Monitor Alerts | Detects conditions requiring operational attention |

## 3. Log Analytics Workspace

The development environment will use a dedicated Log Analytics Workspace.

| Property | Value |
|---|---|
| Name | law-srvfleet-dev-canadacentral-001 |
| Azure Region | Canada Central |
| Retention Period | 30 days |
| Environment | dev |

The workspace will receive telemetry collected from the Windows and Linux virtual machines.

The retention period is configured to balance observability requirements and operational costs.

## 4. Azure Monitor Agent

Azure Monitor Agent will be deployed to both virtual machines.

The agent is responsible for collecting infrastructure metrics and operating system events according to the associated Data Collection Rules.

The monitoring solution will use AMA rather than the legacy Log Analytics agent.

## 5. Data Collection Rules

Data Collection Rules define which telemetry is collected and where it is sent.

The initial monitoring configuration will collect the following data:

### 5.1 Performance Metrics

| Metric | Description |
|---|---|
| CPU Utilization | Measures processor utilization |
| Memory Utilization | Measures memory consumption |
| Disk Utilization | Measures disk resource utilization |
| Heartbeat | Indicates whether the virtual machine is reporting to Azure Monitor |

### 5.2 Windows Event Logs

The Windows virtual machine will collect:

- System
- Application

The Security event log is excluded from the initial implementation.

### 5.3 Linux System Logs

The Linux virtual machine will collect syslog events.

The collection configuration must be compatible with Ubuntu Server 24.04 LTS.

## 6. Alerting Strategy

Azure Monitor Alerts will be configured to detect operational issues.

The initial alert configuration includes:

| Alert | Condition | Evaluation |
|---|---|---|
| VM Heartbeat Missing | No heartbeat received for 5 minutes | 5-minute threshold |
| High CPU Utilization | CPU utilization exceeds 80% | Sustained for 15 minutes |

The alerts are intended to detect virtual machine availability issues and sustained high CPU utilization.

## 7. Alert Notifications

The initial development environment will not include email or SMS notification delivery.

Alert rules will be created and validated independently.

Notification integration may be introduced in a future implementation phase.

## 8. Monitoring Security

The monitoring architecture follows these security principles:

- Telemetry is collected using Azure Monitor Agent.
- Data Collection Rules define the collection scope.
- Log Analytics Workspace access must follow least privilege.
- Security event logs are excluded from the initial implementation.
- Monitoring configuration is managed through Terraform.

## 9. Terraform Implementation

The monitoring infrastructure will be managed through reusable Terraform modules.

The planned modules are:

- `terraform/modules/log-analytics/`
- `terraform/modules/azure-monitor/`

The Log Analytics module will be responsible for creating the workspace.

The Azure Monitor module will be responsible for configuring the monitoring resources, including Data Collection Rules and alert rules.

## 10. Validation Requirements

The monitoring implementation must be validated against the following requirements:

- Log Analytics Workspace is deployed in Canada Central.
- Workspace retention is configured for 30 days.
- Azure Monitor Agent is installed on both virtual machines.
- Windows System and Application logs are collected.
- Ubuntu syslog events are collected.
- CPU, memory, disk, and heartbeat telemetry are collected.
- Heartbeat alert threshold is configured for 5 minutes.
- CPU alert threshold is configured for 80% sustained for 15 minutes.
- Email and SMS notifications are not enabled in the initial implementation.