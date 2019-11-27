resource "azurerm_virtual_network" "vnet" {
  name                  = "VNET-${var.BaseName}-${count.index + 1}"
  location              = "${element(var.Location, count.index)}"
  resource_group_name   = "${var.ResourceGroupName}"
  address_space         = ["${element(var.VnetAddressSpace, count.index)}"]
  ddos_protection_plan  = {
    id                  = "${var.DdosPlanId}"
    enable              = true
  }
  count                 = "${length(var.Location)}"
}
