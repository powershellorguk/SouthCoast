resource "null_resource" "psSetScmIpRestrictions" {
    provisioner "local-exec" {
        command     = ".'${path.module}\\setScmIpRestrictions.ps1' -WebAppId ${azurerm_app_service.WebApp.id} -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}'"
        interpreter = ["PowerShell", "-NoProfile", "-Command"]
    }

    triggers {
        RandomId    = "${uuid()}"
    }

    depends_on      = ["null_resource.psSetWebAppIpRestrictions"]
}
