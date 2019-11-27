variable "resourceGroupName" {
  type  = "string"
}
variable "location" {
  type  = "list"
}
variable "Tags" {
  type  = "map"
}
variable "BaseName" {
  type  = "string"
}
variable "logAnalyticsSku" {
  type    = "string"
  default = "pergb2018"
}

variable "logAnalyticsRetention" {
  type    = "string"
  default = "30"
}
