resource "azurerm_public_ip" "publicIp" {
    name                = "PublicIP-${var.BaseName}-${count.index + 1}"
    resource_group_name = "${var.ResourceGroupName}"
    location            = "${element(var.Location, count.index)}"
    sku                 = "${var.PublicIpConfig["Sku"]}"
    allocation_method   = "${var.PublicIpConfig["AllocationMethod"]}"
    domain_name_label   = "${lower(var.BaseName)}-${count.index + 1}"
    count               = "${length(var.Location)}"
    tags {
        costcode        = "${var.Tags["costcode"]}"
        environment     = "${var.Tags["environment"]}"
        product         = "${var.Tags["product"]}"
    } 
}