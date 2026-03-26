terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tsterraformstate26032026"
    container_name       = "layer1-manual-peering"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
