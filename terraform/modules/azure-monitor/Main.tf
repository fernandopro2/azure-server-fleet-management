resource "azurerm_monitor_data_collection_rule" "windows" {
  name                = "windows-${var.dcrname}"
  resource_group_name = var.rgname
  location            = var.location
  description         = "Collect Windows performance counters and event logs."

  destinations {
    log_analytics {
      name                  = "log-analytics"
      workspace_resource_id = var.workspaceid
    }
  }
  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["log-analytics"]
  }
  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["log-analytics"]
  }
  data_sources {
    dynamic "windows_event_log" {
      for_each = var.windows_monitoring.windows_event_logs
      content {

        name           = windows_event_log.value.name
        streams        = windows_event_log.value.streams
        x_path_queries = windows_event_log.value.x_path_queries
      }
    }
    performance_counter {
      name                          = "windows-performance-counters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = var.windows_monitoring.sampling_frequency_in_seconds

      counter_specifiers = var.windows_monitoring.performance_counters
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "windows" {
  for_each                = var.windows_virtual_machines
  name                    = "${var.dcrname}-${basename(each.value.computer_name)}"
  target_resource_id      = each.value.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows.id
  depends_on              = [azurerm_monitor_data_collection_rule.windows]
}

resource "azurerm_monitor_data_collection_rule" "linux" {
  name                = "linux-${var.dcrname}"
  resource_group_name = var.rgname
  location            = var.location
  description         = "Collect Linux performance counters and syslog."

  destinations {
    log_analytics {
      name                  = "log-analytics"
      workspace_resource_id = var.workspaceid
    }
  }
  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["log-analytics"]
  }
  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log-analytics"]
  }
  data_sources {
    syslog {

      name           = var.linux_monitoring.syslog["name"]
      streams        = var.linux_monitoring.syslog["streams"]
      facility_names = var.linux_monitoring.syslog["facility_names"]
      log_levels     = var.linux_monitoring.syslog["log_levels"]

    }
    performance_counter {
      name                          = "linux-performance-counters"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = var.linux_monitoring.sampling_frequency_in_seconds

      counter_specifiers = var.linux_monitoring.performance_counters
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "linux" {
  for_each                = var.linux_virtual_machines
  name                    = "${var.dcrname}-${basename(each.value.computer_name)}"
  target_resource_id      = each.value.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux.id
  depends_on              = [azurerm_monitor_data_collection_rule.linux]
}

data "azurerm_resource_group" "this" {
  name = var.rgname
}

resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "${var.alertrulename}-cpu"
  resource_group_name = var.rgname
  description         = "Alert when VM CPU usage exceeds 80% for 15 minutes."

  scopes = [data.azurerm_resource_group.this.id]
  //scopes = concat(values(var.windows_virtual_machines).*.id,
  //values(var.linux_virtual_machines).*.id)
  severity    = 2
  enabled     = true
  frequency   = "PT5M"
  window_size = "PT15M"

  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/VirtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

resource "azurerm_monitor_metric_alert" "heartbeat" {
  name                = "${var.alertrulename}-heartbeat"
  resource_group_name = var.rgname
  description         = "Alert when there's no signal for 5 minutes or more."

  scopes      = [var.workspaceid]
  severity    = 2
  enabled     = true
  frequency   = "PT1M"
  window_size = "PT5M"

  target_resource_type     = "Microsoft.OperationalInsights/workspaces"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "Heartbeat"
    aggregation      = "Count"
    operator         = "LessThan"
    threshold        = 5
    dimension {
      name     = "Computer"
      operator = "Include"
      values = concat(values(var.windows_virtual_machines).*.computer_name,
      values(var.linux_virtual_machines).*.computer_name)
    }
  }
  depends_on = [
    azurerm_monitor_scheduled_query_rules_log.heartbeat
  ]
}


resource "azurerm_monitor_scheduled_query_rules_log" "heartbeat" {
  name                = "${var.alertrulename}-heartbeat-log-to-metric"
  resource_group_name = var.rgname
  location            = var.location

  description    = "Convert Azure Monitor Agent Heartbeat records into Azure Monitor metrics."
  data_source_id = var.workspaceid
  enabled        = true

  criteria {
    metric_name = "Heartbeat"

    dimension {
      name     = "Computer"
      operator = "Include"
      values = concat(values(var.windows_virtual_machines).*.computer_name,
      values(var.linux_virtual_machines).*.computer_name)
    }
  }
}
