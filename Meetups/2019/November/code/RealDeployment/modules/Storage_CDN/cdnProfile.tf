resource "azurerm_cdn_profile" "CdnProfile" {
    name	              = "CDN-${var.BaseName}"
    location	          = "${var.Location[0]}"
    resource_group_name	= "${var.ResourceGroupName}"
    sku	                = "${var.CdnProfileSku}"
    tags {
        costcode        = "${var.Tags["costcode"]}"
        environment     = "${var.Tags["environment"]}"
        product         = "${var.Tags["product"]}"
  }
}
