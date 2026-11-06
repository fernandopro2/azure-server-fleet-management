resource "azurerm_resource_group" "this" {
  name     = local.rgname
  location = var.location
}

module "networking" {
  source           = "./modules/networking"
  rgname           = azurerm_resource_group.this.name
  location         = azurerm_resource_group.this.location
  vnetname         = local.vnetname
  addrspace        = var.addrspace
  subnetname       = local.subnetname
  subnetaddrprefix = var.subnetaddrprefix
  bastionname      = var.bastionname
  nsgname          = local.nsgname
}

module "virtual-machines" {
  source    = "./modules/virtual-machine"
  rgname    = azurerm_resource_group.this.name
  location  = azurerm_resource_group.this.location
  subnet_id = module.networking.subnet_id
  vms       = local.vmconfig
}

output "vmconfig" {
  value     = local.vmconfig
  sensitive = false
}
