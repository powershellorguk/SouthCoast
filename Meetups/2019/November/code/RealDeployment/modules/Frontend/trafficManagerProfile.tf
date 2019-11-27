resource "azurerm_traffic_manager_profile" "tmprofile" {
    name                    = "TMP-${var.BaseName}"
    resource_group_name     = "${var.ResourceGroupName}"
    tags {
        costcode            = "${var.Tags["costcode"]}"
        environment         = "${var.Tags["environment"]}"
        product             = "${var.Tags["product"]}"
    }
    traffic_routing_method  = "${var.TrafficManagerProfile["RoutingMethod"]}"
    dns_config {
        relative_name       = "${lower(var.BaseName)}"
        ttl                 = "${var.TrafficManagerProfile["DnsTtl"]}"
    }
    monitor_config {
        protocol            = "${var.TrafficManagerProfile["MonitorProtocol"]}"
        port                = "${var.TrafficManagerProfile["MonitorPort"]}"
        path                = "${var.TrafficManagerProfile["MonitorPath"]}"
    }
}
