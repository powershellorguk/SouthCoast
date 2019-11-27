variable "BaseName" {
  type              = "string"
}
variable "ResourceGroupName" {
  type              = "string"
}
variable "Location" {
  type              = "list"
  default           = ["westeurope","northeurope"]
}
variable "Environments" {
  type              = "list"
  default           = ["dev","test"]
}
variable "Tags" {
  type              = "map"
}

variable "StorageAccountBaseName" {
  type              = "string"
}
variable "StorageAccountConfig" {
  type              = "map"
  default           = {
    Tier            = "Standard"
    Kind            = "StorageV2"
    ReplicationType = "RAGRS"
  }
}
variable "StorageContainerName" {
  type              = "string"
}
variable "StorageQueueNames" {
  type              = "list"
}
variable "StorageContainerType" {
  type              = "string"
  default           = "private"
}

variable "CdnProfileSku" {
  type              = "string"
  default           = "Standard_Microsoft"
}
variable "EndpointConfig" {
  type              = "map"
  default           = {
    HttpAllowed     = false
    HttpsAllowed    = true
    Optimisation    = "GeneralWebDelivery"
  }
}

variable "SubscriptionId" {
  type              = "string"
}
variable "TenantId" {
  type              = "string"
}
variable "ClientId" {
  type              = "string"
}
variable "ClientSecret" {
  type              = "string"
}
