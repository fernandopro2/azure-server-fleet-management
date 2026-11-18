resource "azurerm_public_ip" "bastion" {
  name                = "pip-srvfleet-dev-canadacentral-001"
  allocation_method   = "Static"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.bastionsubnetprefix]
  resource_group_name  = var.rgname
}

resource "azurerm_bastion_host" "this" {
  name                = var.bastionname
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Basic"
  ip_configuration {
    name                 = "bastion-public-ip-config"
    public_ip_address_id = azurerm_public_ip.bastion.id
    subnet_id            = azurerm_subnet.bastion.id
  }
}
