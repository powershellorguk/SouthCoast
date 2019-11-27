resource "azurerm_traffic_manager_endpoint" "endpoint" {
    name                = "TME-${var.BaseName}-${count.index + 1}"
    resource_group_name = "${var.ResourceGroupName}"
    profile_name        = "${azurerm_traffic_manager_profile.tmprofile.name}"
    type                = "${var.TrafficManagerEndpoint["Type"]}"
    target              = "${element(azurerm_public_ip.publicIp.*.fqdn, count.index)}"
    weight              = "${var.TrafficManagerEndpoint["Weight"]}"
    depends_on          = ["azurerm_application_gateway.appgateway"]
    count               = "${length(var.Location)}"
}
