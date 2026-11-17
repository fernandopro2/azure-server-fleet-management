resource "azurerm_maintenance_configuration" "this" {
  name                     = "${var.tags["Env"]}-servers-maintenance"
  location                 = var.location
  resource_group_name      = var.rgname
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = [
        "Critical",
        "Security",
        "UpdateRollup",
        "Updates"
      ]
    }
    linux { classifications_to_include = [
      "Critical",
      "Security"
    ] }
  }
  window {
    start_date_time = "2026-11-17 14:00"
    time_zone       = "Eastern Standard Time"
    recur_every     = "Week"
    duration        = "03:00"

  }
}

resource "azurerm_maintenance_assignment_dynamic_scope" "this" {
  name                         = "dev-servers-dynamic-scope"
  maintenance_configuration_id = azurerm_maintenance_configuration.this.id
  filter {
    resource_types = ["Microsoft.Compute/virtualMachines"]
    tags {
      tag    = "Env"
      values = ["DEV"]
    }
  }
}