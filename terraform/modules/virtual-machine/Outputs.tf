output "linux_virtual_machines" {
  value = {
    for name, vm in azurerm_linux_virtual_machine.this :
    name => vm.id
  }
}

output "windows_virtual_machines" {
  value = {
    for name, vm in azurerm_windows_virtual_machine.this :
    name => vm.id
  }
}
