resource "azurerm_resource_group" "this" {
  name     = local.rgname
  location = var.location
}

//module "networking" {
//  source           = "./modules/networking"
//  rgname           = azurerm_resource_group.this.name
//  location         = azurerm_resource_group.this.location
//  vnetname         = local.vnetname
//  addrspace        = var.addrspace
//  subnetname       = local.subnetname
//  subnetaddrprefix = var.subnetaddrprefix
//  bastionname      = var.bastionname
//  nsgname          = local.nsgname
//}

//module "virtual-machines" {
//  source    = "./modules/virtual-machine"
//  rgname    = azurerm_resource_group.this.name
//  location  = azurerm_resource_group.this.location
//  subnet_id = module.networking.subnet_id
//  vms       = local.vmconfig
//}

module "log-analytics" {
  source       = "./modules/log-analytics"
  location     = azurerm_resource_group.this.location
  rgname       = azurerm_resource_group.this.name
  lawname      = local.lawname
  lawretention = var.lawretention
}

output "lawid" {
  value = module.log-analytics.lawid
}