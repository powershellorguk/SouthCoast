# Web App Deployment Slot
resource "azurerm_app_service_slot" "WebAppSlot" {
  name                = "${var.appslot["Secondary"]}"
  app_service_name    = "${element(azurerm_app_service.WebApp.*.name, count.index)}"
  location            = "${var.Location[count.index]}"
  resource_group_name = "${var.ResourceGroupName}"
  app_service_plan_id = "${element(azurerm_app_service_plan.AppServicePlan.*.id, count.index)}"
  site_config                 = {
    always_on                 =  "${var.SiteConfig["AlwaysOn"]}"
    default_documents         =  "${var.Docs}"
    ftps_state                =  "${var.SiteConfig["Ftp"]}"
    min_tls_version           =  "${var.SiteConfig["Tls"]}"
  }
  count               = "${length(var.Location)}"
  tags {
    costcode          = "${var.Tags["costcode"]}"
    environment       = "${var.Tags["environment"]}"
    product           = "${var.Tags["product"]}"
  }
}
