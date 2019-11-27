resource "null_resource" "testIpAllocation" {
    provisioner "local-exec" {
        command = ".'${path.module}\\Scripts\\Test-PublicIp.ps1' -TenantId ${var.TenantId} -SubscriptionId ${var.SubscriptionId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -PublicIp ${azurerm_public_ip.publicIp.name}"
        interpreter = ["PowerShell","-NoProfile", "-Command"]
    }

    triggers {
        RandomId = uuid()
    }

    depends_on = ["azurerm_public_ip.publicIp","azurerm_application_gateway.appGateway"]
}
