output "linux_virtual_machines" {
  value = {
    for name, vm in azurerm_linux_virtual_machine.this : name => {
      id            = vm.id
      name          = vm.name
      computer_name = vm.computer_name
    }
  }
}

output "windows_virtual_machines" {
  value = {
    for name, vm in azurerm_windows_virtual_machine.this : name => {
      id            = vm.id
      name          = vm.name
      computer_name = vm.computer_name
    }
  }
}
