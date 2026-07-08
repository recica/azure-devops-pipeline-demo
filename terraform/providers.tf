terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }

  # No remote backend configured on purpose — this is a portfolio demo repo,
  # not a shared production environment. In a real team setup, state would
  # live in an azurerm backend (Storage Account + container) instead of local disk.
}

provider "azurerm" {
  features {}
}
