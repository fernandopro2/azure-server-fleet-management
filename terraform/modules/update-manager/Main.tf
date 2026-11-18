resource "azurerm_maintenance_configuration" "this" {
  name                     = "${lower(var.tags["Env"])}-servers-maintenance"
  location                 = var.location
  resource_group_name      = var.rgname
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = var.maintenance_configuration.windows_classifications_to_include
    }
    linux {
      classifications_to_include = var.maintenance_configuration.linux_classifications_to_include
    }
  }
  window {
    start_date_time = var.maintenance_configuration.window.start_date_time
    time_zone       = var.maintenance_configuration.window.time_zone
    recur_every     = var.maintenance_configuration.window.recur_every
    duration        = var.maintenance_configuration.window.duration

  }
}

resource "azurerm_maintenance_assignment_dynamic_scope" "this" {
  name                         = "${lower(var.tags["Env"])}-servers-dynamic-scope"
  maintenance_configuration_id = azurerm_maintenance_configuration.this.id
  filter {
    resource_types = ["Microsoft.Compute/virtualMachines"]
    tags {
      tag    = "Env"
      values = ["DEV"]
    }
  }
}