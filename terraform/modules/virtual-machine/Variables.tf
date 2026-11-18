variable "vms" {
  type = map(object({
    vmname       = string
    computername = string
    size         = string
    os           = string
    image        = string
    storage      = string
    nic          = string
    sku          = string
  }))
}

variable "rgname" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {

}

variable "rg_id" {
  type = string
}
