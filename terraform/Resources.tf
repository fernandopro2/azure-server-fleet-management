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
  nsgname          = local.nsgname
}

module "virtual-machine" {
  source    = "./modules/virtual-machine"
  rgname    = azurerm_resource_group.this.name
  location  = azurerm_resource_group.this.location
  subnet_id = module.networking.subnet_id
  vms       = local.vmconfig
}

module "log-analytics" {
  source       = "./modules/log-analytics"
  location     = azurerm_resource_group.this.location
  rgname       = azurerm_resource_group.this.name
  lawname      = local.lawname
  lawretention = var.lawretention
}

module "azure-monitor" {
  source                   = "./modules/azure-monitor"
  workspaceid              = module.log-analytics.lawid
  rgname                   = local.rgname
  location                 = var.location
  dcrname                  = local.dcrname
  windows_monitoring       = var.windows_monitoring
  windows_virtual_machines = module.virtual-machine.windows_virtual_machines
  linux_virtual_machines   = module.virtual-machine.linux_virtual_machines
  linux_monitoring         = var.linux_monitoring
}

