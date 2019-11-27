resource "null_resource" "configureTrafficManagerProfile" {
  provisioner "local-exec" {
    command = ".'${path.module}\\Scripts\\Update-TrafficManager.ps1' -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -ResourceGroupName ${var.ResourceGroupName} -TrafficManagerProfile ${azurerm_traffic_manager_profile.tmprofile.name} -ProbeUrl '${var.WebsiteUrls["site-a"]}'"
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
  }

  triggers {
    RandomId = "${uuid()}"
  }

  depends_on = ["azurerm_traffic_manager_endpoint.endpoint"]
}
