resource "null_resource" "setIpRestrictions" {
  provisioner "local-exec" {
    command     = ".'${path.module}\\Scripts\\Set-IpRestrictions.ps1' -TenantId ${var.TenantId} -SubscriptionId ${var.SubscriptionId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -ResourceGroup ${var.ResourceGroupName} -WhiteList '${join(",", distinct(concat(var.AppGatewayIps, var.ServiceIps, var.OfficeIps)))}'"
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
  }

  triggers {
    RandomId    = "${uuid()}"
  }

  depends_on    = ["azurerm_app_service.WebApp","azurerm_app_service_slot.WebAppSlot"]
}
