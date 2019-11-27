resource "azurerm_cdn_endpoint" "CdnEndpoint" {
    name	                        = "EP-${var.BaseName}-${count.index + 1}"
    profile_name	                = "${azurerm_cdn_profile.CdnProfile.name}"
    location	                    = "${var.Location[0]}"
    tags {
        costcode                    = "${var.Tags["costcode"]}"
        environment                 = "${var.Tags["environment"]}"
        product                     = "${var.Tags["product"]}"
    }
    resource_group_name	            = "${var.ResourceGroupName}"
    is_http_allowed	                = "${var.EndpointConfig["HttpAllowed"]}"
    is_https_allowed	            = "${var.EndpointConfig["HttpsAllowed"]}"
    optimization_type	            = "${var.EndpointConfig["Optimisation"]}"
    querystring_caching_behaviour   = "NotSet"
    origin_host_header	            = "${replace(replace(element(azurerm_storage_account.StorageAccount.*.primary_blob_endpoint, count.index), "https://",""),"/","")}"
    origin {
        name	                    = "EPO-${var.BaseName}-${count.index + 1}"
        host_name	                = "${replace(replace(element(azurerm_storage_account.StorageAccount.*.primary_blob_endpoint, count.index), "https://",""),"/","")}"
    }
    count                           = "${length(var.Environments)}"
}
