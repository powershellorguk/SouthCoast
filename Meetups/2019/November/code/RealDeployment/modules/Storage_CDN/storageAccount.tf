resource "azurerm_storage_account" "StorageAccount" {
  name                      = "sa${lower(var.StorageAccountBaseName)}${element(var.Environments, count.index)}"
  resource_group_name       = "${var.ResourceGroupName}"
  location                  = "${var.Location[0]}"
  account_tier              = "${var.StorageAccountConfig["Tier"]}"
  account_kind              = "${var.StorageAccountConfig["Kind"]}"
  account_replication_type	= "${var.StorageAccountConfig["ReplicationType"]}"
  count                     = "${length(var.Environments)}"
  tags {
    costcode                = "${var.Tags["costcode"]}"
    environment             = "${var.Tags["environment"]}"
    product                 = "${var.Tags["product"]}"
  }
}
