variable "BaseName" {
  type      = "string"
}
variable "Location" {
  type      = "list"
  default   = ["westeurope","northeurope"]
}
variable "ResourceGroupName" {
  type      = "string"
}
variable "AppInsightsConfig" {
  type      = "map"
  default   = {
    Type    = "Web"
  }
}
variable "Tags" {
  type      = "map"
}
