resource "azurerm_subnet" "subnet" {
    name                        = "SUBNET-${var.BaseName}-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    virtual_network_name        = "${element(azurerm_virtual_network.vnet.*.name, count.index)}"
    address_prefix              = "${element(var.SubnetAddressPrefix, count.index)}"
    count                       = "${length(var.Location)}"
    network_security_group_id   = "${azurerm_network_security_group.NetworkSecurityGroup.*.id[count.index]}"
}