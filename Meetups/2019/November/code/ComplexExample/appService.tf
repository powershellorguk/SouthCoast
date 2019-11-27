resource "azurerm_app_service_plan" "webAppPlan" {
    name                                = "ASP-${var.BaseName}-${var.Environment}"
    location                            = "${var.Location}"
    resource_group_name                 = "${azurerm_resource_group.resourceGroup.name}"
    sku {
        tier                            = "${var.AppTier}"
        size                            = "${var.AppSize}"
    }
}

resource "azurerm_app_service" "webApp" {
    name                                = "WA-${var.BaseName}-${var.Environment}"
    location                            = "${var.Location}"
    resource_group_name                 = "${azurerm_resource_group.resourceGroup.name}"
    app_service_plan_id                 = "${azurerm_app_service_plan.webAppPlan.id}"
    connection_string {
        name                            = "${azurerm_sql_database.sqlDatabase.name}"
        type                            = "SQLServer"
        value                           = "Server=${azurerm_sql_server.sqlServer.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sqlDatabase.name};User ID=${var.SqlAdmin}; Password=${var.SqlPassword};"
    }
    https_only                          = "${var.AppHttpsOnly}"
    site_config {
        ftps_state                      = "${var.AppFtpState}"
    }
}
