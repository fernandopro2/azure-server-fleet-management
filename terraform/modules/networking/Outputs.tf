output "subnet_id" {
  value = azurerm_subnet.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}
