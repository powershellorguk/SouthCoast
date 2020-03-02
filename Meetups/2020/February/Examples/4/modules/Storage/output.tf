output "sakeys" {
  value = [azurerm_storage_account.sa.primary_access_key, azurerm_storage_account.sa.secondary_access_key]
}
output "saurl" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}
