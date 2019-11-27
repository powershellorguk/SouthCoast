# General Variables
variable "BaseName" {
  type        = "string"
}
variable "Location" {
  type        = "list"
  default     = ["europewest","europenorth"]
}
variable "Tags" {
  type        = "map"
}

# Resource Group Variables
variable "ResourceGroupName" {
  type        = "string"
}

# SQL Variables
variable "SqlConfig" {
  type        = "map"
  default     = {
    Username  = ""
    Password  = ""
  }
}

variable "AllowIpsInFirewalls" {
  type        = "string"
}

# Database Variables
variable "DatabaseSkus" {
  type        = "map"
}
variable "appslot" {
  type        = "map"
}
variable "clientDBName" {
  type        = "list"
}

# Script Variables
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
