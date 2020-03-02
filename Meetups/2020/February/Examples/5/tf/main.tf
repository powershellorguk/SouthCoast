resource "azurerm_resource_group" "rg" {
    name        = "RG-${var.BaseName}"
    location    = var.Region
    tags        = var.Tags
}

resource "azurerm_app_service_plan" "asp" {
    name                = "ASP-${var.BaseName}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.Region
    
    sku {
        tier            = "Free"
        size            = "F1"
    }
    
    tags                = var.Tags
}

resource "azurerm_app_service" "as" {
    name                = "AS-${var.BaseName}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.Region
    app_service_plan_id = azurerm_app_service_plan.asp.id

    site_config {
        default_documents           = ["index.htm"]
        min_tls_version             = "1.2"
        use_32_bit_worker_process   = true
    }

    tags                = var.Tags
}
