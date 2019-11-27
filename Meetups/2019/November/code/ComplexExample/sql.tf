resource "azurerm_sql_server" "sqlServer" {
    name                                = "sql-${lower(var.BaseName)}-${lower(var.Environment)}"
    location                            = "${var.Location}"
    resource_group_name                 = "${azurerm_resource_group.resourceGroup.name}"
    version                             = "${var.SqlVersion}"
    administrator_login                 = "${var.SqlAdmin}"
    administrator_login_password        = "${var.SqlPassword}"
}

resource "azurerm_sql_database" "sqlDatabase" {
    name                                = "DB-${var.DbName}-${var.Environment}"
    location                            = "${var.Location}"
    resource_group_name                 = "${azurerm_resource_group.resourceGroup.name}"
    server_name                         = "${azurerm_sql_server.sqlServer.name}"
    edition                             = "${var.DbEdition}"
    max_size_bytes                      = "${var.DbSize}"
    requested_service_objective_name    = "${var.DbTier}"
}
