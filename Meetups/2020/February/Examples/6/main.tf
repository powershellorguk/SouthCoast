resource "azurerm_resource_group" "rg" {
    name                    = "RG-TF12"
    location                = "ukwest"
}

resource "azurerm_virtual_network" "vnet" {
    resource_group_name     = azurerm_resource_group.rg.name
    name                    = each.key
    address_space           = [each.value]
    location                = azurerm_resource_group.rg.location
    for_each                = var.vnets

    dynamice "subnet" {
        for_each            = var.subnets[each.key]

        content {
            name            = subnet.key
            address_prefix  = subnet.value
        }
    }
}
