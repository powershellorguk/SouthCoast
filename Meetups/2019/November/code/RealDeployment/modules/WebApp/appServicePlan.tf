# Create Service Plan
resource "azurerm_app_service_plan" "AppServicePlan" {
  name                = "ASP-${var.BaseName}-${count.index + 1}"
  location            = "${var.Location[count.index]}"
  resource_group_name = "${var.ResourceGroupName}"
  kind                = "${var.PlanSettings["Kind"]}"
  tags {
    costcode          = "${var.Tags["costcode"]}"
    environment       = "${var.Tags["environment"]}"
    product           = "${var.Tags["product"]}"
  }
  sku {
    tier              = "${var.PlanSettings["Tier"]}"
    size              = "${var.PlanSettings["Size"]}"
    capacity          = "${var.PlanSettings["Capacity"]}"
  }
  count               = "${length(var.Location)}"
}
