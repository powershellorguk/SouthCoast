output "WebAppUrl" {
  value = ["${azurerm_app_service.WebApp.*.default_site_hostname}"]
}
output "WebAppResourceId" {
  value = ["${azurerm_app_service.WebApp.*.id}"]
}
output "WebAppPublicIps" {
  value = ["${azurerm_app_service.WebApp.*.possible_outbound_ip_addresses}"]
}
output "WebAppNames" {
  value = ["${azurerm_app_service.WebApp.*.name}"]
}
output "WebAppSlotName" {
  value =  ["${azurerm_app_service_slot.WebAppSlot.*.name}"]
}
