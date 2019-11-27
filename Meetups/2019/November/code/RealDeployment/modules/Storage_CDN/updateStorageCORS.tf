resource "null_resource" "updateStorageCORS" {
  provisioner "local-exec" {
    command = ".'${path.module}\\Scripts\\Update-StorageCORS.ps1' -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}' -ResourceGroupName ${var.ResourceGroupName}"
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
  }

  triggers {
    RandomId = "${uuid()}"
  }

  depends_on = ["azurerm_storage_account.StorageAccount"]
  count = "${length(var.Location)}"
}
