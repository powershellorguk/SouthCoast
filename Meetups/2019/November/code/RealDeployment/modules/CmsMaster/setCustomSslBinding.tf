resource "null_resource" "psSetCustomSslBinding" {
    provisioner "local-exec" {
        command     = ".'${path.module}\\setCustomSslBinding.ps1' -TenantId ${var.TenantId} -SubscriptionId ${var.SubscriptionId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -ResourceGroup ${var.ResourceGroupName} -WebAppName ${azurerm_app_service.WebApp.name} -WebAppCustomDomain ${var.CustomDomain["Primary"]} -WebappSlotCustomDomain ${var.CustomDomain["Secondary"]} -SslCertificate '${var.SslPath}' -SslPassword ${var.SslPassword}"
        interpreter = ["PowerShell", "-NoProfile", "-Command"]
    }
}
