variable "rgname" {
  type = string
}

variable "location" {
  type = string
}

variable "dcrname" {
  type = string
}

variable "workspaceid" {
  type = string
}

variable "windows_monitoring" {
  description = "Windows virtual machine monitoring configuration."

  type = object({
    sampling_frequency_in_seconds = number

    performance_counters = list(string)

    windows_event_logs = list(object({
      name           = string
      streams        = list(string)
      x_path_queries = list(string)
    }))
  })
}

variable "linux_monitoring" {
  description = "Linux virtual machine monitoring configuration."

  type = object({
    sampling_frequency_in_seconds = number

    performance_counters = list(string)

    syslog = object({
      name           = string
      streams        = list(string)
      facility_names = list(string)
      log_levels     = list(string)
    })
  })
}

variable "windows_virtual_machines" {
}

variable "linux_virtual_machines" {
}

variable "alertrulename" {
  type = string
}
