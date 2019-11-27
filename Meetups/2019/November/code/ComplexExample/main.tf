provider "azurerm" {
    version                             = "~> 1.36"
}

resource "azurerm_resource_group" "resourceGroup" {
    name                                = "RG-${var.BaseName}-${var.Environment}"
    location                            = "${var.Location}"
}
