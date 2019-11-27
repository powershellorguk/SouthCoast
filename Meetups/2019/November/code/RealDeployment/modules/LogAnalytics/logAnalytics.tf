resource "azurerm_log_analytics_workspace" "LA" {
  name                        = "LA-${var.BaseName}"
  location                    = "${var.location[0]}"
  resource_group_name         = "${var.resourceGroupName}"
  sku                         = "${var.logAnalyticsSku}"
  retention_in_days           = "${var.logAnalyticsRetention}"
  tags {
    costcode                  = "${var.Tags["costcode"]}"
    environment               = "${var.Tags["environment"]}"
    product                   = "${var.Tags["product"]}"
  }
}
