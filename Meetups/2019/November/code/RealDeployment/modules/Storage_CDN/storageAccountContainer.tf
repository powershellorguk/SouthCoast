resource "azurerm_storage_container" "StorageContainer" {
  name                  = "${var.StorageContainerName}"
  resource_group_name   = "${var.ResourceGroupName}"
  storage_account_name  = "${element(azurerm_storage_account.StorageAccount.*.name, count.index)}"
  container_access_type = "${var.StorageContainerType}"
  count                 = "${length(var.Environments)}"
}
