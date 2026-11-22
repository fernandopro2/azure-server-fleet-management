variable "vnetname" {
  type = string
}

variable "location" {
  type = string
}

variable "rgname" {
  type = string
}

variable "addrspace" {
  type = list(string)
}

variable "subnetaddrprefix" {
  type = list(string)
}

variable "subnetname" {
  type = string
}

variable "nsgname" {
  type = string
}