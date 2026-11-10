resource "azurerm_monitor_data_collection_rule" "windows" {
  name                = var.dcrname
  resource_group_name = var.rgname
  location            = var.location
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
  name                    = "${var.dcrname}-${each.value.computer_name}"
  target_resource_id      = each.value.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows.id
}