# Create Web App
resource "azurerm_app_service" "WebApp" {
  name                        = "WA-${var.BaseName}-Master"
  location                    = "${var.Location}"
  resource_group_name         = "${var.ResourceGroupName}"
  tags {
    costcode                  = "${var.Tags["costcode"]}"
    environment               = "${var.Tags["environment"]}"
    product                   = "${var.Tags["product"]}"
  }
  app_service_plan_id         = "${azurerm_app_service_plan.AppServicePlan.id}"
  https_only                  = true
  site_config                 = {
    always_on                 =  "${var.SiteConfig["AlwaysOn"]}"
    default_documents         =  "${var.Docs}"
    ftps_state                =  "${var.SiteConfig["Ftp"]}"
    min_tls_version           =  "${var.SiteConfig["Tls"]}"
  }
}
