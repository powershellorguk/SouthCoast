resource "null_resource" "testIpAllocation" {
    provisioner "local-exec" {
        command     = ".'${path.module}\\Scripts\\Test-IpAllocated.ps1' -ResourceGroup ${var.ResourceGroupName} -SubscriptionId ${var.SubscriptionId} -TenantId ${var.TenantId} -ClientId ${var.ClientId} -ClientSecret '${var.ClientSecret}'"
        interpreter = ["PowerShell", "-NoProfile", "-Command"]
    }

    triggers {
        RandomId    = "${uuid()}"
    }

    depends_on      = ["azurerm_application_gateway.appgateway", "azurerm_public_ip.publicIp"]
}

data "azurerm_public_ip" "publicIpOutput" {
    name                = "${element(azurerm_public_ip.publicIp.*.name, count.index)}"
    resource_group_name = "${var.ResourceGroupName}"

    count               = "${length(var.Location)}"
    depends_on          = ["null_resource.testIpAllocation"]
}
