variable "BaseName" {}
variable "Region" {}
variable "Tags" {
    description = "Tags to apply to all resources"
    type        = map
    default     = {
        Environment = "Dev"
        BuiltWith   = "Terraform"
    }
}
