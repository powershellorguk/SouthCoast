resource "azurerm_storage_account" "sa" {
    name                        = var.Name
    resource_group_name         = var.ResourceGroup
    location                    = var.Region
    account_kind                = "StorageV2"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    access_tier                 = "Hot"
    enable_https_traffic_only   = true
    tags                        = var.Tags
}

resource "azurerm_storage_container" "sc" {
    name                    = var.Containers[count.index]
    storage_account_name    = azurerm_storage_account.sa.name
    container_access_type   = "private"
    count                   = length(var.Containers)
}
