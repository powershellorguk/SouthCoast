output "ResourceGroupName" {
  value = "${azurerm_resource_group.ResourceGroup.name}"
}
output "SqlServerNames" {
  value = "${module.Sql.ServerNames}"
}
output "SqlDatabaseNames_StagingSlot" {
  value = "${module.Sql.DatabaseNames_StageSlot}"
}
output "SqlDatabaseNames_ProdSlot" {
  value = "${module.Sql.DatabaseNames_ProdSlot}"
}
output "WebAppNames" {
  value = "${module.WebApp.WebAppNames}"
}
output "WebAppSlotName" {
  value = "${element(module.WebApp.WebAppSlotName,0)}"
}
output "WebAppIds" {
  value = "${module.WebApp.WebAppResourceId}"
}
output "AccessKeys" {
  value = "${module.CdnStorageHA.AccessKeys}"
}
output "CdnEndpoints" {
  value = "${module.CdnStorageHA.CdnEndpoints}"
}
output "StorageAccountNames" {
  value = "${module.CdnStorageHA.StorageAccountNames}"
}
output "AppGatewayNames" {
  value = "${module.AppGatewayHA.AppGatewayNames}"
}
output "DatabaseBaseName" {
  value = "${module.Sql.DatabaseBaseName}"
}
output "CmsMasterUrls" {
  value = "${module.cmsMaster.CmsMasterUrls}"
}
output "CmsMasterName" {
  value = "${module.cmsMaster.WebAppName}"
}
 