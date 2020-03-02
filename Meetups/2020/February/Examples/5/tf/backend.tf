terraform {
    backend "azurerm" {
        storage_account_name    = "tfstate"
        container_name          = "tfstate"
        key                     = "demo.tfstate"
    }
}