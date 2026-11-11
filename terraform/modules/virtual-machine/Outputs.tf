output "linux_virtual_machines" {
  value = azurerm_linux_virtual_machine.this
}

output "windows_virtual_machines" {
  value = azurerm_windows_virtual_machine.this
}

output "vms_ids" {
  value = concat(values(azurerm_windows_virtual_machine.this).*.id,
  values(azurerm_linux_virtual_machine.this).*.id)
}