variable "BaseName" {
  type                  = "string"
}
variable "Location" {
  type                  = "list"
  default               = ["westeurope","northeurope"]
}
variable "Environment" {
  type                  = "string"
}
variable "ResourceGroupName" {
  type                  = "string"
}
variable "Tags" {
  type                  = "map"
}

variable "VnetAddressSpace" {
  type                  = "list"
}
variable "DdosPlanId" {
  type                  = "string"
}
variable "SubnetAddressPrefix" {
  type                  = "list"
}
variable "PublicIpConfig" {
  type                  = "map"
  default               = {
    Sku                 = "Basic"
    AllocationMethod    = "Dynamic"
  }
}

variable "AppGatewayBackendConfig" {
  type                  = "map"
  default               = {
    Cookies             = "Enabled"
    Port                = "443"
    Protocol            = "Https"
    RequestTimeout      = "30"
  }
}
variable "AppGatewayBackendFqdns" {
  type                  = "list"
  default               = []
}

variable "AppGatewayMiscConfig" {
  type                  = "map"
  default               = {
    FrontendPort        = "443"
    RedirectPort        = "80"
    ListenerProtocol    = "Https"
    RedirectProtocol    = "Http"
    RedirectRuleType    = "Basic"
    RuleType            = "Basic"
    SkuName             = "WAF_Medium"
    SkuTier             = "WAF"
    SkuCapacity         = "2"
  }

}
variable "AppGatewayProbeConfig" {
  type                  = "map"
  default               = {
    Interval            = "30"
    Protocol            = "Https"
    Path                = "/"
    Timeout             = "30"
    UnhealthyThreshold  = "3"
    HostFromBackend     = true
  }
}
variable "AppGatewayWafConfig" {
  type                  = "map"
  default               = {
    RuleType            = "OWASP"
    RuleVersion         = "3.0"
    Mode                = "Prevention"
    UploadLimit         = "100"
    MaxRequestBodySize  = "128"
  }
}
variable "AppGatewayWafEnabled" {
  type                  = "string"
  default               = "true"
}


variable "TrafficManagerProfile" {
  type                  = "map"
  default               = {
    RoutingMethod       = "Weighted"
    DnsTtl              = "90"
    MonitorProtocol     = "HTTPS"
    MonitorPort         = "443"
    MonitorPath         = "/"
  }
}
variable "TrafficManagerEndpoint" {
  type                  = "map"
  default               = {
    Type                = "externalEndpoints"
    Weight              = "1"
  }
}
variable "SslPath" {
  type                  = "string"
}
variable "SslPassword" {
  type                  = "string"
}
variable "SslPolicy" {
  type                  = "string"
  default               = "AppGwSslPolicy20170401S"
}
variable "AppGatewayWafMode" {
  type                  = "string"
  default               = "Prevention"
}
variable "OfficeIps" {
  type                  = "list"
  default               = [""]
}
variable "ThirdPartyIps" {
  type                  = "map"
  default               = {
    default             = "0.0.0.0/32"
  }
}
variable "ThirdParties" {
  type                  = "string"
  default               = "No"
}
variable "ServiceIps" {
  type                  = "list"
  default               = [""]
}
variable "AppGatewayPermittedServiceTag" {
  type                  = "string"
  default               = "None"
}
variable "WebsiteUrls" {
  type                  = "map"
}
variable "WebsiteSlotUrls" {
  type                  = "map"
}
variable "RedirectUrls" {
  type                  = "map"
}
variable "logAnalyticsRetention" {
  type                  = "string"
  default               = "30"
}
variable "RedirectType" {
  type                  = "string"
}
variable "WorkspaceId" {
  type                  = "string"
}

# checkIpAllocated Script Variables
variable "SubscriptionId" {
  type                  = "string"
}
variable "TenantId" {
  type                  = "string"
}
variable "ClientId" {
  type                  = "string"
}
variable "ClientSecret" {
  type                  = "string"
}
