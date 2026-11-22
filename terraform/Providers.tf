terraform {

  cloud {
    organization = "fernandosantos-org"
    workspaces {
      tags = ["azure-server-fleet-management"]
    }
  }

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

provider "random" {

}

provider "azuread" {

}