# General Variables
variable "BaseName" {
  type        = "string"
}
variable "Location" {
  type        = "list"
  default     = ["westeurope","northeurope"]
}
variable "Tags" {
  type        = "map"
}
variable "appslot" {
  type        = "map"
}

# Resource Group Variables
variable "ResourceGroupName" {
  type        = "string"
}

# App Service Plan Variables
variable "PlanSettings" {
  type        = "map"
  default     = {
    Kind      = "Windows"
    Tier      = "Standard"
    Size      = "S1"
    Capacity  = 2
  }
}

# Web App Variables
variable "AppSettings" {
  type        = "map"
  default     = {}
}
variable "SiteConfig" {
  type        =  "map"
  default     = {
    AlwaysOn  =   true
    Ftp       =  "Disabled"
    Tls       =  "1.2"
  }
}
variable "Docs" {
  type        = "list"
  default     = ["Default.htm","Default.html","Default.asp","index.htm","index.html","iisstart.htm","default.aspx","index.php","hostingstart.html"]
}

# IP Whitelisting
variable "AppGatewayIps" {
  type        = "list"
}
variable "ServiceIps" {
  type        = "list"
}
variable "OfficeIps" {
  type        = "list"
}

# setScmIpRestrictions Script Variables
variable "SubscriptionId" {
  type        = "string"
}
variable "TenantId" {
  type        = "string"
}
variable "ClientId" {
  type        = "string"
}
variable "ClientSecret" {
  type        = "string"
}
