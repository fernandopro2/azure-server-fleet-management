resource "random_integer" "this" {
  min = 1000
  max = 9999
}

resource "random_id" "vms" {
  for_each    = var.vms
  byte_length = 2
}

locals {

  regions_short = {
    "canadacentral" = "cac"
    "brazilsouth"   = "brs"
  }
  location = local.regions_short[var.location]
  rgname   = "rg-${var.project}-${var.environment}-${local.location}-${random_integer.this.result}"
  vnetname = "vnet-${var.project}-${var.environment}-${local.location}-${random_integer.this.result}"
  lawname  = "law-${var.project}-${var.environment}-${local.location}-${random_integer.this.result}"
  dcrname  = "dcr-${var.project}-${var.environment}-${local.location}-${random_integer.this.result}"

  subnetname = "snet-${var.project}-${var.environment}-${local.location}-${random_integer.this.result}"
  //vmname     = "vm-${var.project}-${substr(var.vms.os, 0, 2)}-${var.environment}-${var.location}-${random_integer.this.result}"
  nsgname = "nsg-${var.project}-${var.environment}-${local.location}-${random_integer.this.result}"
  vmconfig = {
    for name, vm in var.vms :
    name => {
      computername = upper("srv-${substr(vm.os, 0, 1)}-${var.environment}-${random_id.vms[name].hex}")
      vmname       = "vm-${lower(substr(vm.os, 0, 3))}-${var.project}-${var.environment}-${local.location}-${random_id.vms[name].hex}"
      nic          = "nic-${lower(substr(vm.os, 0, 3))}-${var.project}-${var.environment}-${local.location}-${random_id.vms[name].hex}"
      size         = vm.size
      os           = vm.os
      image        = vm.image
      storage      = vm.storage
      sku          = vm.sku
    }
  }
}
