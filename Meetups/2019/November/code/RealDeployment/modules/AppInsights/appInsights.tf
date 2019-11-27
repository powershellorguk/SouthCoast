resource "azurerm_application_insights" "AppInsight" {
  name                = "AI-${var.BaseName}"
  location            = "${var.Location[0]}"
  resource_group_name = "${var.ResourceGroupName}"
  application_type    = "${var.AppInsightsConfig["Type"]}"
  tags {
    costcode          = "${var.Tags["costcode"]}"
    environment       = "${var.Tags["environment"]}"
    product           = "${var.Tags["product"]}"
  }
}
