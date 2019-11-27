output "BlobEndpoints" {
  value = "${map("${var.Environments[0]}", "${azurerm_storage_account.StorageAccount.0.primary_blob_endpoint}", "${var.Environments[1]}", "${azurerm_storage_account.StorageAccount.1.primary_blob_endpoint}")}"
}
output "AccessKeys" {
  value = "${map("${var.Environments[0]}", "${azurerm_storage_account.StorageAccount.0.primary_access_key}", "${var.Environments[1]}", "${azurerm_storage_account.StorageAccount.1.primary_access_key}")}"
}
output "ConnectionStrings" {
  value = "${map("${var.Environments[0]}", "${azurerm_storage_account.StorageAccount.0.primary_blob_connection_string}", "${var.Environments[1]}", "${azurerm_storage_account.StorageAccount.1.primary_blob_connection_string}")}"
}
output "CdnEndpoints" {
  value = "${map("${var.Environments[0]}", "${azurerm_cdn_endpoint.CdnEndpoint.0.host_name}", "${var.Environments[1]}", "${azurerm_cdn_endpoint.CdnEndpoint.1.host_name}")}"
}
output "StorageAccountNames" {
  value = "${map("${var.Environments[0]}", "sa${lower(var.StorageAccountBaseName)}${var.Environments[0]}", "${var.Environments[1]}", "sa${lower(var.StorageAccountBaseName)}${var.Environments[1]}")}"
}
