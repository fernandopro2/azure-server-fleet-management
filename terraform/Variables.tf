variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "srvfleet"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "addrspace" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "subnetaddrprefix" {
  type    = list(string)
  default = ["10.10.0.0/24"]
}

variable "bastionsubnetprefix" {
  type = string
}

variable "vms" {
  type = map(object({
    size    = string
    os      = string
    image   = string
    storage = string
    sku     = string
  }))
}

variable "lawretention" {
  type = number
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

variable "maintenance_configuration" {
  type = object({
    reboot                             = string
    windows_classifications_to_include = list(string)
    linux_classifications_to_include   = list(string)
    window = object({
      start_date_time = string
      time_zone       = string
      recur_every     = string
      duration        = string
    })
  })
}
