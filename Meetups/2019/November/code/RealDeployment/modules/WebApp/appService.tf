# Create Web App Pair
resource "azurerm_app_service" "WebApp" {
  name                        = "WA-${var.BaseName}-${count.index + 1}"
  location                    = "${var.Location[count.index]}"
  resource_group_name         = "${var.ResourceGroupName}"
  tags {
    costcode                  = "${var.Tags["costcode"]}"
    environment               = "${var.Tags["environment"]}"
    product                   = "${var.Tags["product"]}"
  }
  app_service_plan_id         = "${element(azurerm_app_service_plan.AppServicePlan.*.id,count.index)}"
  https_only                  = true
  site_config                 = {
    always_on                 =  "${var.SiteConfig["AlwaysOn"]}"
    default_documents         =  "${var.Docs}"
    ftps_state                =  "${var.SiteConfig["Ftp"]}"
    min_tls_version           =  "${var.SiteConfig["Tls"]}"
  }
  count                       = "${length(var.Location)}"
}
