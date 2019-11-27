resource "azurerm_network_security_group" "NetworkSecurityGroup" {
    name                    = "NSG-${var.BaseName}-${count.index + 1}"
    resource_group_name     = "${var.ResourceGroupName}"
    location                = "${var.Location[count.index]}"
    count                   = "${length(var.Location)}"
    tags {
        costcode            = "${var.Tags["costcode"]}"
        environment         = "${var.Tags["environment"]}"
        product             = "${var.Tags["product"]}"
    } 
}
