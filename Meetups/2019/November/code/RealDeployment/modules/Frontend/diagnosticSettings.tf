resource "azurerm_monitor_diagnostic_setting" "AGdiagnosticsetting" {
  name                        = "AG-${var.BaseName}-${count.index + 1}-diag"
  log_analytics_workspace_id  = "${var.WorkspaceId}"
  target_resource_id          = "${azurerm_application_gateway.appgateway.*.id[count.index]}"
  count                       = "${length(var.Location)}"
  log {
    category                    = "ApplicationGatewayAccessLog"
    enabled                     = true
    retention_policy {
      enabled                   = true
      days                      = "${var.logAnalyticsRetention}"
    }
  }
  log {
    category                    = "ApplicationGatewayPerformanceLog"
    enabled                     = true
    retention_policy {
      enabled                   = true
      days                      = "${var.logAnalyticsRetention}"
    }
  }
  log {
    category                    = "ApplicationGatewayFirewallLog"
    enabled                     = true
    retention_policy {
      enabled                   = true
      days                      = "${var.logAnalyticsRetention}"
    }
  }
}
resource "azurerm_monitor_diagnostic_setting" "NSGdiagnosticsetting" {
  name                          = "NSG-${var.BaseName}-${count.index + 1}-diag"
  log_analytics_workspace_id    = "${var.WorkspaceId}"
  target_resource_id            = "${azurerm_network_security_group.NetworkSecurityGroup.*.id[count.index]}"
  count                         = "${length(var.Location)}"
  log {
    category                    = "NetworkSecurityGroupEvent"
    enabled                     = true
    retention_policy {
      enabled                   = true
      days                      = "${var.logAnalyticsRetention}"
    }
  }
  log {
    category                    = "NetworkSecurityGroupRuleCounter"
    enabled                     = true
    retention_policy {
      enabled                   = true
      days                      = "${var.logAnalyticsRetention}"
    }
  }
}
