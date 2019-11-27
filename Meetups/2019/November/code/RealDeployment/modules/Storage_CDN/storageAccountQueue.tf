resource "azurerm_storage_queue" "StorageQueue1" {
  name                 = "${element(var.StorageQueueNames, 0)}"
  resource_group_name  = "${var.ResourceGroupName}"
  storage_account_name = "${element(azurerm_storage_account.StorageAccount.*.name, count.index)}"
  count                 = "${length(var.Environments)}"
}

resource "azurerm_storage_queue" "StorageQueue2" {
  name                 = "${element(var.StorageQueueNames, 1)}"
  resource_group_name  = "${var.ResourceGroupName}"
  storage_account_name = "${element(azurerm_storage_account.StorageAccount.*.name, count.index)}"
  count                 = "${length(var.Environments)}"
}