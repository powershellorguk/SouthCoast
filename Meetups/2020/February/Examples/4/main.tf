resource "azurerm_resource_group" "rg" {
    name        = "RG-${var.BaseName}"
    location    = var.Region
    tags        = var.Tags
}

module "storage" {
    source          = "./modules/Storage"
    Name            = "sa${lower(var.BaseName)}"
    ResourceGroup   = azurerm_resource_group.rg.name
    Region          = var.Region
    Containers      = var.ContainerNames
    Tags            = var.Tags
}

module "storage2" {
    source          = "./modules/Storage"
    Name            = "sa${lower(var.BaseName)}2"
    ResourceGroup   = azurerm_resource_group.rg.name
    Region          = var.Region
    Containers      = [lower(var.BaseName)]
    Tags            = var.Tags
}

