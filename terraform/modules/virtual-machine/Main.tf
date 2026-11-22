resource "azurerm_network_interface" "this" {
  resource_group_name = var.rgname
  location            = var.location
  for_each            = var.vms
  name                = each.value.nic
  ip_configuration {
    name                          = "nic-config"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }
}

data "azurerm_key_vault_secret" "windows-pass" {
  name         = "windows-pass"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "linux-pass" {
  name         = "linux-pass"
  key_vault_id = var.key_vault_id
}

resource "azurerm_windows_virtual_machine" "this" {
  for_each = {
    for name, vm in var.vms : name => vm
    if vm.os == "Windows"
  }
  name                = each.value.vmname
  computer_name       = each.value.computername
  location            = var.location
  resource_group_name = var.rgname
  os_disk {
    storage_account_type = each.value.storage
    caching              = "None"
    name                 = "${each.value.computername}-OS-DISK"
  }
  network_interface_ids = [azurerm_network_interface.this[each.key].id]
  size                  = each.value.size
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = each.value.sku
    version   = "latest"
  }
  admin_username = "adminuser"
  // configurar keyvault
  admin_password = data.azurerm_key_vault_secret.windows-pass.value
  identity {
    type = "SystemAssigned"
  }
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = "true"
  tags                                                   = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = {
    for name, vm in var.vms : name => vm
    if vm.os == "Linux"
  }
  name                = each.value.vmname
  computer_name       = each.value.computername
  location            = var.location
  resource_group_name = var.rgname
  os_disk {
    storage_account_type = each.value.storage
    caching              = "None"
    name                 = "${each.value.computername}-OS-DISK"

  }
  network_interface_ids = [azurerm_network_interface.this[each.key].id]
  size                  = each.value.size
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = each.value.sku
    version   = "latest"
  }
  identity {
    type = "SystemAssigned"
  }
  disable_password_authentication                        = false
  admin_username                                         = "adminuser"
  admin_password                                         = data.azurerm_key_vault_secret.linux-pass.value // configurar keyvault
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = "true"
  tags                                                   = var.tags
}

resource "azurerm_virtual_machine_extension" "entra-ssh" {
  for_each = {
    for name, vm in var.vms : name => vm
    if vm.os == "Linux"
  }
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "entra-rdp" {
  for_each = {
    for name, vm in var.vms : name => vm
    if vm.os == "Windows"
  }
  name                       = "AADLogin"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "ama-windows" {
  for_each = {
    for name, vm in var.vms : name => vm
    if vm.os == "Windows"
  }
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

}

resource "azurerm_virtual_machine_extension" "ama-linux" {
  for_each = {
    for name, vm in var.vms : name => vm
    if vm.os == "Linux"
  }
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

}

data "azuread_group" "linux_admins" {
  display_name = "Linux Admins"
}

data "azuread_group" "windows_admins" {
  display_name = "Windows Admins"
}

resource "azurerm_role_assignment" "vms_rbac" {
  scope                = var.rg_id
  for_each             = toset([data.azuread_group.linux_admins.object_id, data.azuread_group.windows_admins.object_id])
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = each.value
}