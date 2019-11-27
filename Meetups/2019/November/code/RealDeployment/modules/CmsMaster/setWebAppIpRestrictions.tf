resource "null_resource" "psSetWebAppIpRestrictions" {
    provisioner "local-exec" {
        command     = ".'${path.module}\\setWebAppIpRestrictions.ps1' -ResourceGroup '${var.ResourceGroupName}' -WebApp ${azurerm_app_service.WebApp.name} -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -IPWhitelist '${join(",",distinct(concat(var.ServiceIps,var.OfficeIps)))}'"
        interpreter = ["PowerShell", "-NoProfile", "-Command"]
    }

    triggers {
        RandomId    = "${uuid()}"
    }

    depends_on      = ["azurerm_app_service.WebApp"]
}

resource "null_resource" "psSetWebAppSlotIpRestrictions" {
    provisioner "local-exec" {
        command     = ".'${path.module}\\setWebAppIpRestrictions.ps1' -ResourceGroup '${var.ResourceGroupName}' -WebApp ${azurerm_app_service.WebApp.name} -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -IPWhitelist '${join(",",distinct(concat(var.ServiceIps,var.OfficeIps)))}' -SlotName '${var.appslot["Secondary"]}'"
        interpreter = ["PowerShell", "-NoProfile", "-Command"]
    }

    triggers {
        RandomId    = "${uuid()}"
    }

    depends_on      = ["azurerm_app_service_slot.WebAppSlot"]
}
