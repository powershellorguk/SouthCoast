resource "null_resource" "setSslPolicy" {
  provisioner "local-exec" {
    command = ".'${path.module}\\Scripts\\Set-SslPolicy.ps1' -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -ResourceGroupName ${var.ResourceGroupName} -SslPolicy ${var.SslPolicy}"
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
  }

  triggers {
    RandomId = "${uuid()}"
  }

  depends_on = ["azurerm_application_gateway.appgateway"]
}
