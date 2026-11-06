resource "azurerm_virtual_network" "this" {
  name                = var.vnetname
  location            = var.location
  resource_group_name = var.rgname
  address_space       = var.addrspace
}

resource "azurerm_subnet" "this" {
  name                 = var.subnetname
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnetaddrprefix
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-srvfleet-dev-canadacentral-001"
  allocation_method   = "Static"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.this.name
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

resource "azurerm_network_security_group" "this" {
  name                = var.nsgname
  location            = var.location
  resource_group_name = var.rgname
  security_rule {
    name                       = "allow-bastion-rdp"
    destination_address_prefix = "*"
    source_address_prefix      = "10.10.1.0/26"
    source_port_range          = "*"
    destination_port_range     = "3389"
    access                     = "Allow"
    protocol                   = "Tcp"
    priority                   = 110
    direction                  = "Inbound"

  }
  security_rule {
    name                       = "allow-bastion-ssh"
    destination_address_prefix = "*"
    source_address_prefix      = "10.10.1.0/26"
    source_port_range          = "*"
    destination_port_range     = "22"
    access                     = "Allow"
    protocol                   = "Tcp"
    priority                   = 120
    direction                  = "Inbound"

  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  network_security_group_id = azurerm_network_security_group.this.id
  subnet_id                 = azurerm_subnet.this.id
}

