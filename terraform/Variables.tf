variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "srvfleet"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "addrspace" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "subnetaddrprefix" {
  type    = list(string)
  default = ["10.10.0.0/24"]
}

variable "bastionname" {
  type    = string
  default = "bas-srvfleet-dev-canadacentral-001"
}

variable "vms" {
  type = map(object({
    size    = string
    os      = string
    image   = string
    storage = string
    sku     = string
  }))
}