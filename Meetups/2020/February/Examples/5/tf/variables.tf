variable "BaseName" {
    type    = string
}
variable "Region" {
    type    = string
    default = "ukwest"
}
variable "Tags" {
    type    = map
    default = {
        Environment = "Dev"
        BuiltWith   = "Terraform"
    }
}
