resource "azurerm_log_analytics_workspace" "this" {
  name                = var.lawname
  location            = var.location
  resource_group_name = var.rgname
  retention_in_days   = var.lawretention
}

output "lawid" {
  value = azurerm_log_analytics_workspace.this.id
}