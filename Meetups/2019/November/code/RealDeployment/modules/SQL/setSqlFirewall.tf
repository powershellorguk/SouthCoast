resource "null_resource" "setSqlFirewall" {
    provisioner "local-exec" {
        command     = ".'${path.module}\\Scripts\\Set-SqlFirewall.ps1' -TenantId ${var.TenantId} -SubscriptionId ${var.SubscriptionId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -ResourceGroup ${var.ResourceGroupName} -IpWhitelist '${var.AllowIpsInFirewalls}'"
        interpreter = ["PowerShell", "-NoProfile", "-Command"]
    }

    triggers {
        RandomId    = "${uuid()}"
    }

    depends_on      = ["azurerm_template_deployment.ArmDeployment"]
}
