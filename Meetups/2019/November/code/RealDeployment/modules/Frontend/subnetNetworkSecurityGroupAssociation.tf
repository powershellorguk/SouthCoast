resource "azurerm_subnet_network_security_group_association" "SubnetSecurityGroupAssociation" {
    subnet_id                   = "${azurerm_subnet.subnet.*.id[count.index]}"
    network_security_group_id   = "${azurerm_network_security_group.NetworkSecurityGroup.*.id[count.index]}"
    count                       = "${length(var.Location)}"
}
