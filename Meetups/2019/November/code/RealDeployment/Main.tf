#region Resource Group
resource "azurerm_resource_group" "ResourceGroup" {
  name                                = "RG-${var.BaseName}${var.Environment}"
  location	                          = "${var.Location[0]}"
  tags {
    costcode                          = "${var.Tags["costcode"]}"
    environment                       = "${var.Tags["environment"]}"
    product                           = "${var.Tags["product"]}"
  }
}
#endregion

#region HA Web Apps
module "WebApp" {
  source	                            = "./modules/WebApp"
  BaseName                            = "${var.BaseName}${var.Environment}"
  Location                            = ["${var.Location}"]
  ResourceGroupName	                  = "${azurerm_resource_group.ResourceGroup.name}"
  AppGatewayIps                       = "${module.Frontend.PublicIps}"
  ServiceIps                          = "${var.WhitelistIpsAzure}"
  OfficeIps                           = "${var.WhitelistIpsInternal}"
  appslot                             = {
      Primary                         = "${var.appslot["Primary"]}"
      Secondary                       = "${var.appslot["Secondary"]}"
  }
  PlanSettings                        = {
      Kind                            = "${var.PlanSettings["Kind"]}"
      Tier                            = "${var.PlanSettings["Tier"]}"
      Size                            = "${var.PlanSettings["Size"]}"
      Capacity                        = "${var.PlanSettings["Capacity"]}"
  }
  SubscriptionId                      = "${var.subscription_id}"
  TenantId                            = "${var.tenant_id}"
  ClientId                            = "${var.client_id}"
  ClientSecret                        = "${var.client_secret}"
  Tags                                = {
      costcode                        = "${var.Tags["costcode"]}"
      environment                     = "${var.Tags["environment"]}"
      product                         = "${var.Tags["product"]}"
  }
}
#endregion

#region AppTagging
resource "null_resource" "AppTagging" {
  provisioner "local-exec" {
    command     = ".'${path.root}\\Scripts\\AppTagging.ps1' -TenantId ${var.tenant_id} -SubscriptionId ${var.subscription_id} -ClientId ${var.client_id} -ClientSecret '${var.client_secret}' -ResourceGroup ${azurerm_resource_group.ResourceGroup.name} -WebApp ${element(module.WebApp.WebAppNames, count.index)} -SlotName ${var.appslot["Secondary"]} -SettingName 'AppSlot' -SettingValue ${element(var.clientDBName, 1)} -AppInsightsKey ${module.AppInsights.InstrumentationKey}"
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
  }

  triggers {
    RandomId    = "${uuid()}"
  }

  count           = "${length(var.Location)}"
  depends_on      = ["module.WebApp"]
}

resource "null_resource" "AppTagging_slot" {
  provisioner "local-exec" {
    command     = ".'${path.root}\\Helpers\\Scripts.ps1' -TenantId ${var.tenant_id} -SubscriptionId ${var.subscription_id} -ClientId ${var.client_id} -ClientSecret '${var.client_secret}' -ResourceGroup ${azurerm_resource_group.ResourceGroup.name} -WebApp ${element(module.WebApp.WebAppNames, count.index)} -SlotName ${var.appslot["Secondary"]} -SettingName 'AppSlot' -SettingValue ${element(var.clientDBName, 0)} -AppInsightsKey ${module.AppInsights.InstrumentationKey} -Updateslot"
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
  }

  triggers {
    RandomId    = "${uuid()}"
  }

  count           = "${length(var.Location)}"
  depends_on      = ["module.WebApp"]
}
#endregion

#region HA SQL
module "Sql" {
  source	                            = "./modules/SQL"
  BaseName                            = "${var.BaseName}${var.Environment}"
  Location                            = ["${var.Location}"]
  ResourceGroupName	                  = "${azurerm_resource_group.ResourceGroup.name}"
  SqlConfig                           = {
      Username                        = "${var.SqlAdminUsername}"
      Password                        = "${var.SqlAdminPassword}"
  }
  appslot                             = {
      Primary                         = "${var.appslot["Primary"]}"
      Secondary                       = "${var.appslot["Secondary"]}"
  }
  AllowIpsInFirewalls                 = "${join(",",distinct(concat(split(",",replace(join(",",concat(var.WhitelistIpsInternal,var.WhitelistIpsAzure)),"/32","")))))}"
  DatabaseSkus                        = "${var.DatabaseSkus}"
  Tags                                = {
      costcode                        = "${var.Tags["costcode"]}"
      environment                     = "${var.Tags["environment"]}"
      product                         = "${var.Tags["product"]}"
  }
  clientDBName                        = "${var.clientDBName}"
  SubscriptionId                      = "${var.subscription_id}"
  TenantId                            = "${var.tenant_id}"
  ClientId                            = "${var.client_id}"
  ClientSecret                        = "${var.client_secret}"
}
#endregion

#region Storage Account
module "StorageCdn" {
  source                              = "./modules/Storage_CDN"
  BaseName                            = "${var.BaseName}${var.Environment}"
  ResourceGroupName	                  = "${azurerm_resource_group.ResourceGroup.name}"
  Location                            = ["${var.Location}"]
  StorageAccountBaseName              = "${var.BaseName}"
  StorageContainerName                = "${var.StorageContainerName}"
  StorageContainerType                = "${var.StorageContainerType}"
  StorageQueueNames                   = "${var.StorageQueueNames}"
  CdnProfileSku                       = "${var.CdnProfile}"
  Environments                        = "${var.StorageAccountEnvironments}"
  SubscriptionId                      = "${var.subscription_id}"
  TenantId                            = "${var.tenant_id}"
  ClientId                            = "${var.client_id}"
  ClientSecret                        = "${var.client_secret}"
  Tags                                = {
      costcode                        = "${var.Tags["costcode"]}"
      environment                     = "${var.Tags["environment"]}"
      product                         = "${var.Tags["product"]}"
  }
}
#endregion

#region App Gateway
module "Frontend" {
  source                              = "./modules/Frontend"
  BaseName                            = "${var.BaseName}${var.Environment}"
  Environment                         = "${var.Environment}"
  Location                            = ["${var.Location}"]
  ResourceGroupName                   = "${azurerm_resource_group.ResourceGroup.name}"
  VnetAddressSpace                    = ["${var.VnetAddressSpace}"]
  SubnetAddressPrefix                 = ["${var.SubnetAddressPrefix}"]
  DdosPlanId                          = "${var.DdosPlanId}"
  AppGatewayBackendConfig             = {
    Cookies                           = "${var.AppGatewayConfig["Cookies"]}"
    Port                              = "${var.AppGatewayConfig["Port"]}"
    Protocol                          = "${var.AppGatewayConfig["Protocol"]}"
    RequestTimeout                    = "${var.AppGatewayConfig["Timeout"]}"
  }
  AppGatewayBackendFqdns              = ["wa-${var.BaseName}${var.Environment}-1.azurewebsites.net","wa-${var.BaseName}${var.Environment}-2.azurewebsites.net","wa-${var.BaseName}${var.Environment}-1-${var.appslot["Secondary"]}.azurewebsites.net","wa-${var.BaseName}${var.Environment}-2-${var.appslot["Secondary"]}.azurewebsites.net"]
  SslPath                             = "${var.SslPath}/"
  SslPassword                         = "${var.SslPassword}"
  SslPolicy                           = "${var.SslPolicy}"
  AppGatewayWafMode                   = "${var.AppGatewayWafMode}"
  AppGatewayWafEnabled                = "${var.AppGatewayWafEnabled}"
  OfficeIps                           = ["${var.WhitelistIpsInternal}"]
  ThirdParties                        = "${var.ExternalWhitelisting}"
  ThirdPartyIps                       = "${var.WhitelistIpsExternal}"
  ServiceIps                          = ["${var.WhitelistIpsAzure}"]
  AppGatewayPermittedServiceTag       = "${var.ApplicationTrafficPermittedTag}"
  WebsiteUrls                         = "${var.WebsiteUrls}"
  WebsiteSlotUrls                     = "${var.WebsiteSlotUrls}"
  RedirectUrls                        = "${var.RedirectUrls}"
  RedirectType                        = "${var.RedirectType}"
  SubscriptionId                      = "${var.subscription_id}"
  TenantId                            = "${var.tenant_id}"
  ClientId                            = "${var.client_id}"
  ClientSecret                        = "${var.client_secret}"
  WorkspaceId                         = "${module.LogAnalytics.WorkspaceId}"
  logAnalyticsRetention               = "${var.logAnalyticsRetention}"
  Tags                                = {
      costcode                        = "${var.Tags["costcode"]}"
      environment                     = "${var.Tags["environment"]}"
      product                         = "${var.Tags["product"]}"
  }
}
#endregion

#region AppInsights
module "AppInsights" {
  source                              = "./modules/AppInsights"
  BaseName                            = "${var.BaseName}${var.Environment}"
  Location                            = ["${var.Location}"]
  ResourceGroupName                   = "${azurerm_resource_group.ResourceGroup.name}"
  Tags                                = {
      costcode                        = "${var.Tags["costcode"]}"
      environment                     = "${var.Tags["environment"]}"
      product                         = "${var.Tags["product"]}"
  }
}
module "LogAnalytics" {
  source                              = "./modules/LogAnalytics"
  BaseName                            = "${var.BaseName}${var.Environment}"
  location                            = ["${var.Location}"]
  logAnalyticsRetention               = "${var.logAnalyticsRetention}"
  logAnalyticsSku                     = "${var.logAnalyticsSku}"
  resourceGroupName                   = "${azurerm_resource_group.ResourceGroup.name}"
  Tags                                = {
    costcode                          = "${var.Tags["costcode"]}"
    environment                       = "${var.Tags["environment"]}"
    product                           = "${var.Tags["product"]}"
  }
}
#endregion

#region cmsMaster WebApp
module "cmsMaster" {
  source                              = "./modules/CmsMaster"
  BaseName                            = "${var.BaseName}${var.Environment}"
  Location                            = "${var.Location[0]}"
  appslot                             = {
    Primary                           = "${var.appslot["Primary"]}"
    Secondary                         = "${var.appslot["Secondary"]}"
  }
  ResourceGroupName                   = "${azurerm_resource_group.ResourceGroup.name}"
  ServiceIps                          = "${var.WhitelistIpsAzure}"
  OfficeIps                           = "${var.WhitelistIpsInternal}"
  SubscriptionId                      = "${var.subscription_id}"
  TenantId                            = "${var.tenant_id}"
  ClientId                            = "${var.client_id}"
  ClientSecret                        = "${var.client_secret}"
  Tags                                = {
      costcode                        = "${var.Tags["costcode"]}"
      environment                     = "${var.Tags["environment"]}"
      product                         = "${var.Tags["product"]}"
  }
  CustomDomain                        = {
    Primary                           = "${var.CustomDomain["Primary"]}"
    Secondary                         = "${var.CustomDomain["Secondary"]}"
  }
  SslPath                             = "${var.SslPath}/Site-a-Slot.pfx"
  SslPassword                         = "${var.SslPassword}"
}
#endregion
