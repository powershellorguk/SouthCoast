output "PublicIpId" {
    description = "ID of Public IPs created."
    value = ["${azurerm_public_ip.publicIp.*.id}"]
}
output "PublicIps" {
  value = ["${data.azurerm_public_ip.publicIpOutput.*.ip_address}"]
}
output "PublicIpFqdns" {
  value = ["${azurerm_public_ip.publicIp.*.fqdn}"]
}
output "PublicIpNames" {
  value = ["${azurerm_public_ip.publicIp.*.name}"]
}
output "AppGatewayIds" {
  value = ["${azurerm_application_gateway.appgateway.*.id}"]
}
output "AppGatewayNames" {
  value = ["${azurerm_application_gateway.appgateway.*.name}"]
}
