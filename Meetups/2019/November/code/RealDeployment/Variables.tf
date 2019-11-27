#region General Variables
variable "BaseName" {
    description = "Base Name for deployment, used to to generate all resource names."
    type        = "string"
}
variable "Location" {
    description = "Location list to be used for deployment, specified as a primary first and secondary second. Defaults to Europe West/North respectively."
    type        = "list"
    default     = ["westeurope", "northeurope"]
}
variable "Environment" {
    description = "Environment Name. Used in conjunction with BaseName to generate resource names."
    type        = "string"
}
variable "Tags" {
    description = "Map of tags to be applied to resource group."
    type        = "map"
}

#endregion

#region Provider Variables
variable "subscription_id" {
    description = "Azure Subscription ID"
}
variable "tenant_id" {
    description = "Azure Tenant ID"
}
variable "client_id" {
    description = "Azure Client ID"
}
variable "client_secret" {
    description = "Azure Client Secret"
}
#endregion

#region IP Whitelist
variable "WhitelistIpsInternal" {
    description = "List of IPs to allow access to the various backend components."
    type        = "list"
}
variable "ExternalWhitelisting" {
    description = "Switch to specify if third party IPs need to be added to whitelist or not."
    type        = "string"
}

variable "WhitelistIpsExternal" {
    description = "Map of IPs to allow access to the various backend components."
    type        = "map"
}
variable "WhitelistIpsAzure" {
    description = "List of IPs to allow access to the various backend components. Populated with Azure services. Applied to webapps and SQL"
    type        = "list"
}
#endregion

#region SQL Failover Group Variables
variable "SqlAdminUsername" {
    description = "SQL Admin username."
    type        = "string"
    default     = "dbadmin"
}
variable "SqlAdminPassword" {
    description = "SQL Admin Password"
    type        = "string"
}
#endregion

#region SQL Database Variables
variable "DatabaseSkus" {
    description     = "Map of database SKUs."
    type            = "map"
    default         = {
        Client      = "S2"
        Logs        = "S0"
        Services    = "S0"
    }
}
variable "clientDBName" {
  description = "Name of the client DB for each environment. This is distinct from app slot as client DB is sticky to slot. "
  type        = "list"
}
#endregion

#region Storage Account Variables
variable "StorageContainerName" {
    description = "Storage Container Name"
    type        = "string"
}
variable "StorageContainerType" {
    description = "Storage container access type"
    type        = "string"
}
variable "StorageAccountEnvironments" {
    description = "List of Environments that Storage Accounts are being deployed for"
    type        = "list"
}
variable "StorageQueueNames" {
    description = "Name of storage queue attached to storage accounts"
    type        = "list"
}
variable "CdnProfile" {
    description = "CDN Profile SKU"
    type        = "string"
}

#endregion

#region AppGateway Variables
variable "VnetAddressSpace" {
    description = "Vnet Address Space for AppGateways"
    type        = "list"
}
variable "SubnetAddressPrefix" {
    description = "Subnet Address Prefix for AppGateways"
    type        = "list"
}
variable "SslPath" {
  description   = "Path to Private SSL Certificate to be deployed to Application Gateways."
  type          = "string"
}
variable "SslPassword" {
    description = "Password for SSL Certificate to be deployed on to Application Gateways."
    type        = "string"
}
variable "SslPolicy" {
    description = "Predefined Azure GW Policy. Applies TLS and Cipher settings"
    type        = "string"
}
variable "AppGatewayConfig" {
    description = "Map of values for configuring the AppGateway Backends."
    type        = "map"
}

variable "AppGatewayWafMode" {
    description = "Mode for WAF to be deployed in. Options are 'Detection' and'Prevention'."
    type        = "string"
}
variable "AppGatewayWafEnabled" {
    description = "Enabled true/false for WAF on AppGateway."
    type        = "string"
}

variable "ApplicationTrafficPermittedTag" {
  description   = "Service Tag to permit traffic to AppGateways. Use 'None' to ignore and values such as 'Internet' to allow access."
  type          = "string"
}
variable "WebsiteUrls" {
  description   = "Map of website URLs."
  type          = "map"
}
variable "WebsiteSlotUrls" {
  description   = "Map of website slot URLs."
  type          = "map"
}
variable "RedirectUrls" {
  description   = "Map of website URLS used to facilatate direction to www. addresses."
  type          = "map"
}
variable "DdosPlanId" {
  description   = "Resource ID of the DDoS plan to be used."
  type          = "string"
}

variable "logAnalyticsSku" {
    description   = "Log analytics sizing sku"
    type          = "string"
}

variable "logAnalyticsRetention" {
    description   = "Length of days data is retained. Set in both each log and globally in Log Analytics"
    type          = "string"
}
variable "RedirectType" {
    description   = "Type of redirection to be used. Allowed values are 'Permanent', 'Temporary', 'Found' and 'Other'."
    type          = "string"
}
#endregion

#region web app Variables
variable "PlanSettings" {
    description   = "Map of settings to be used to create App Service Plan. 'Kind', 'Tier', 'Size' and 'Capacity' are required. Defaults to 'Windows', 'Standard', 'S1' and '2'."
    type          = "map"
}

variable "appslot" {
    description   = "Used to keep track of current which WebApp is in which slot"
    type          = "map"
}
#endregion

#region CMS Master
variable "CustomDomain" {
    description = "Map of custom domains to be used with the CMS Master web app instance, for authoring content and internal CMS scheduling."
    type        = "map"
}
#endregion
