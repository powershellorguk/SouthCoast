resource "azurerm_application_gateway" "appgateway" {
    name                = "AG-${var.BaseName}-${count.index + 1}"
    resource_group_name = "${var.ResourceGroupName}"
    location            = "${element(var.Location, count.index)}"
    tags {
        costcode    = "${var.Tags["costcode"]}"
        environment = "${var.Tags["environment"]}"
        product     = "${var.Tags["product"]}"
    }
    # Backend Pool
    backend_address_pool {
        name    = "BackendPool"
        fqdns   = ["${element(var.AppGatewayBackendFqdns, count.index)}"]
    }
    backend_address_pool {
        name    = "BackendPool-Slot"
        fqdns   = ["${element(var.AppGatewayBackendFqdns, count.index + 2)}"]
    }
    # Backend Settings - No URL/Path re-write
    backend_http_settings {
        name                                = "BackendHttpSettings"
        cookie_based_affinity               = "${var.AppGatewayBackendConfig["Cookies"]}"
        affinity_cookie_name                = "GatewayAffinity"
        port                                = "${var.AppGatewayBackendConfig["Port"]}"
        protocol                            = "${var.AppGatewayBackendConfig["Protocol"]}"
        request_timeout                     = "${var.AppGatewayBackendConfig["RequestTimeout"]}"
        probe_name                          = "Probe"
        pick_host_name_from_backend_address =  true
    }
    backend_http_settings {
        name                                = "BackendHttpSettings-Slot"
        cookie_based_affinity               = "${var.AppGatewayBackendConfig["Cookies"]}"
        affinity_cookie_name                = "GatewayAffinity"
        port                                = "${var.AppGatewayBackendConfig["Port"]}"
        protocol                            = "${var.AppGatewayBackendConfig["Protocol"]}"
        request_timeout                     = "${var.AppGatewayBackendConfig["RequestTimeout"]}"
        probe_name                          = "Probe"
        pick_host_name_from_backend_address = true
    }
    # Frontend IP & Port Settings
    frontend_ip_configuration {
        name                    = "FrontendIp"
        public_ip_address_id    = "${element(azurerm_public_ip.publicIp.*.id, count.index)}"
    }
    frontend_port {
        name    = "FrontendPort-Https"
        port    = "${var.AppGatewayMiscConfig["FrontendPort"]}"
    }
    frontend_port {
        name    = "FrontendPort-Http"
        port    = "${var.AppGatewayMiscConfig["RedirectPort"]}"
    }
    # Gateway IP
    gateway_ip_configuration {
        name        = "GatewayIp"
        subnet_id   = "${element(azurerm_subnet.subnet.*.id, count.index)}"
    }
    # SSL Certificates
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),0)}"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),0)}.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),1)}"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),1)}.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),2)}"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),2)}.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),3)}"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),3)}.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),0)}-Slot"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),0)}-Slot.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),1)}-Slot"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),1)}-Slot.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),2)}-Slot"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),2)}-Slot.pfx"))}"
        password    = "${var.SslPassword}"
    }
    ssl_certificate {
        name        = "SslCert-${element(keys(var.WebsiteUrls),3)}-Slot"
        data        = "${base64encode(file("${var.SslPath}/${element(keys(var.WebsiteUrls),3)}-Slot.pfx"))}"
        password    = "${var.SslPassword}"
    }
    # HTTP Listeners - HTTPS
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),0)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),0)}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),0)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),1)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),1)}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),1)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),2)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),2)}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),2)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),3)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),3)}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),3)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),0)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),0)}-Slot"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),0)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),1)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),1)}-Slot"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),1)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),2)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),2)}-Slot"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),2)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    http_listener {
        name                            = "Listener-Https-${element(keys(var.WebsiteUrls),3)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),3)}-Slot"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),3)]}"
        custom_error_configuration {
            status_code             = "HttpStatus403"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn2.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-403.htm"}"
        }
        custom_error_configuration {
            status_code             = "HttpStatus502"
            custom_error_page_url   = "${var.Environment == "Prod" ? "https://cdn1.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm" : "https://cdntest.mydomain.com/custom-errors/${element(keys(var.WebsiteUrls),0)}-502.htm"}"
        }
    }
    # HTTP Listeners - HTTPS Redirect
    http_listener {
        name                            = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),0)}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),0)]}"
    }
    http_listener {
        name                            = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),1)}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),1)]}"
    }
    http_listener {
        name                            = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),2)}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),2)]}"
    }
    http_listener {
        name                            = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Https"
        protocol                        = "${var.AppGatewayMiscConfig["ListenerProtocol"]}"
        require_sni                     = true
        ssl_certificate_name            = "SslCert-${element(keys(var.WebsiteUrls),3)}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),3)]}"
    }
    # HTTP Listeners - HTTP
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),0)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),0)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),1)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),1)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),2)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),2)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),3)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteUrls[element(keys(var.WebsiteUrls),3)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),0)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),0)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),1)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),1)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),2)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),2)]}"
    }
    http_listener {
        name                            = "Listener-Http-${element(keys(var.WebsiteUrls),3)}-Slot"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.WebsiteSlotUrls[element(keys(var.WebsiteUrls),3)]}"
    }
    # HTTP Listeners: HTTP Redirect
    http_listener {
        name                            = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),0)]}"
    }
    http_listener {
        name                            = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),1)]}"
    }
    http_listener {
        name                            = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),2)]}"
    }
    http_listener {
        name                            = "Listener-Http-UrlRedirect-${element(keys(var.WebsiteUrls),3)}"
        frontend_ip_configuration_name  = "FrontendIp"
        frontend_port_name              = "FrontendPort-Http"
        protocol                        = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                       = "${var.RedirectUrls[element(keys(var.RedirectUrls),3)]}"
    }                        

    # Probe Settings
    probe {
        name                                        = "Probe"
        interval                                    = "${var.AppGatewayProbeConfig["Interval"]}"
        protocol                                    = "${var.AppGatewayProbeConfig["Protocol"]}"
        path                                        = "${var.AppGatewayProbeConfig["Path"]}"
        timeout                                     = "${var.AppGatewayProbeConfig["Timeout"]}"
        unhealthy_threshold                         = "${var.AppGatewayProbeConfig["UnhealthyThreshold"]}"
        pick_host_name_from_backend_http_settings   = "${var.AppGatewayProbeConfig["HostFromBackend"]}"
    }
    # Routing Rules - CMS Sites
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),0)}"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),0)}"
        backend_address_pool_name   = "BackendPool"
        backend_http_settings_name  = "BackendHttpSettings"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),1)}"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),1)}"
        backend_address_pool_name   = "BackendPool"
        backend_http_settings_name  = "BackendHttpSettings"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),2)}"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),2)}"
        backend_address_pool_name   = "BackendPool"
        backend_http_settings_name  = "BackendHttpSettings"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),3)}"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),3)}"
        backend_address_pool_name   = "BackendPool"
        backend_http_settings_name  = "BackendHttpSettings"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),0)}-Slot"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),0)}-Slot"
        backend_address_pool_name   = "BackendPool-Slot"
        backend_http_settings_name  = "BackendHttpSettings-Slot"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),1)}-Slot"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),1)}-Slot"
        backend_address_pool_name   = "BackendPool-Slot"
        backend_http_settings_name  = "BackendHttpSettings-Slot"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),2)}-Slot"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),2)}-Slot"
        backend_address_pool_name   = "BackendPool-Slot"
        backend_http_settings_name  = "BackendHttpSettings-Slot"
    }
    request_routing_rule {
        name                        = "HttpsRouting-${element(keys(var.WebsiteUrls),3)}-Slot"
        rule_type                   = "${var.AppGatewayMiscConfig["RuleType"]}"
        http_listener_name          = "Listener-Https-${element(keys(var.WebsiteUrls),3)}-Slot"
        backend_address_pool_name   = "BackendPool-Slot"
        backend_http_settings_name  = "BackendHttpSettings-Slot"
    }
    # Routing Rules - HTTP->HTTPS Redirects
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),0)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),0)}"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),0)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),0)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),0)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),1)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),1)}"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),1)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),1)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),1)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),2)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),2)}"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),2)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),2)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),2)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),3)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),3)}"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),3)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),3)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),3)}"
        include_path            = true
        include_query_string    = false
    }
    # Routing Rules - HTTP->HTTPS Redirects (Slots)
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),0)}-Slot"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),0)}-Slot"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),0)}-Slot"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),0)}-Slot"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),0)}-Slot"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),1)}-Slot"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),1)}-Slot"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),1)}-Slot"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),1)}-Slot"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),1)}-Slot"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),2)}-Slot"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),2)}-Slot"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),2)}-Slot"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),2)}-Slot"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),2)}-Slot"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-${element(keys(var.WebsiteUrls),3)}-Slot"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-${element(keys(var.WebsiteUrls),3)}-Slot"
        redirect_configuration_name = "Redirect-Http-${element(keys(var.WebsiteUrls),3)}-Slot"
    }
    redirect_configuration {
        name                    = "Redirect-Http-${element(keys(var.WebsiteUrls),3)}-Slot"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),3)}-Slot"
        include_path            = true
        include_query_string    = false
    }
    # Routing Roules: Redirect URL (HTTPS) > HTTPS Website URL
    request_routing_rule {
        name                        = "HttpsRouting-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        redirect_configuration_name = "Redirect-Https-${element(keys(var.RedirectUrls),0)}"
    }
    redirect_configuration {
        name                    = "Redirect-Https-${element(keys(var.RedirectUrls),0)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),0)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpsRouting-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        redirect_configuration_name = "Redirect-Https-${element(keys(var.RedirectUrls),1)}"
    }
    redirect_configuration {
        name                    = "Redirect-Https-${element(keys(var.RedirectUrls),1)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),1)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpsRouting-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        redirect_configuration_name = "Redirect-Https-${element(keys(var.RedirectUrls),2)}"
    }
    redirect_configuration {
        name                    = "Redirect-Https-${element(keys(var.RedirectUrls),2)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),2)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpsRouting-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Https-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
        redirect_configuration_name = "Redirect-Https-${element(keys(var.RedirectUrls),3)}"
    }
    redirect_configuration {
        name                    = "Redirect-Https-${element(keys(var.RedirectUrls),3)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),3)}"
        include_path            = true
        include_query_string    = false
    }
    # Routing Roules: Redirect URL (HTTP) > HTTPS Website URL
    request_routing_rule {
        name                        = "HttpRouting-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        redirect_configuration_name = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),0)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),0)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        redirect_configuration_name = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),1)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),1)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        redirect_configuration_name = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),2)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),2)}"
        include_path            = true
        include_query_string    = false
    }
    request_routing_rule {
        name                        = "HttpRouting-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
        rule_type                   = "Basic"
        http_listener_name          = "Listener-Http-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
        redirect_configuration_name = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
    }
    redirect_configuration {
        name                    = "Redirect-Http-UrlRedirect-${element(keys(var.RedirectUrls),3)}"
        redirect_type           = "${var.RedirectType}"
        target_listener_name    = "Listener-Https-${element(keys(var.WebsiteUrls),3)}"
        include_path            = true
        include_query_string    = false
    }
    # Redirects - External Sites
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),0)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 0)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 0)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),0)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),0)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),1)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 1)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 1)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),1)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),1)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),2)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 2)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 2)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),2)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),2)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),3)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 3)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 3)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),3)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),3)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),4)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 4)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 4)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),4)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),4)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),5)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 5)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 5)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),5)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),5)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),6)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 6)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 6)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),6)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),6)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),7)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 7)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 7)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),7)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),7)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),8)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 8)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 8)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),8)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),8)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),9)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 9)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 9)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),9)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),9)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),10)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 10)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 10)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),10)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),10)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),11)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 11)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 11)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),11)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),11)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),12)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 12)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 12)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),12)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),12)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),13)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 13)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 13)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),13)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),13)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),14)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 14)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 14)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),14)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),14)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),15)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 15)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 15)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),15)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),15)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),16)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 16)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 16)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),16)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),16)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),17)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 17)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 17)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),17)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),17)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),18)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 18)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 18)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),18)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),18)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),19)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 19)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 19)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),19)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),19)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),20)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 20)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 20)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),20)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),20)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),21)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 21)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 21)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),21)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),21)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),22)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 22)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 22)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),22)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),22)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),23)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 23)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 23)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),23)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),23)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),24)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 24)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 24)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),24)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),24)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),25)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 25)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 25)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),25)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),25)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),26)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 26)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 26)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),26)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),26)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),27)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 27)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 27)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),27)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),27)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),28)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 28)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 28)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),28)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),28)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),29)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 29)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 29)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),29)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),29)]}"

    }
    http_listener {
        name                                        = "Listener-Http-${element(keys(var.RedirectUrls),30)}"
        frontend_ip_configuration_name              = "FrontendIp"
        frontend_port_name                          = "FrontendPort-Http"
        protocol                                    = "${var.AppGatewayMiscConfig["RedirectProtocol"]}"
        host_name                                   = "${var.RedirectUrls[element(keys(var.RedirectUrls), 30)]}"
    }
    request_routing_rule {
        name                                        = "RedirectRule-${element(keys(var.RedirectMap), 30)}"
        rule_type                                   = "${var.AppGatewayMiscConfig["RedirectRuleType"]}"
        http_listener_name                          = "Listener-Http-${element(keys(var.RedirectMap),30)}"
        redirect_configuration_name                 = "Redirect-${var.RedirectMap[element(keys(var.RedirectMap),30)]}"

    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),0)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 0)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),1)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 1)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),2)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 2)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),3)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 3)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),4)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 4)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),5)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 5)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),6)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 6)]}"
        include_path                                = false
        include_query_string                        = false
    }
    redirect_configuration {
        name                                        = "Redirect-${element(keys(var.RedirectTargets),7)}"
        redirect_type                               = "${var.RedirectType}"
        target_url                                  = "${var.RedirectTargets[element(keys(var.RedirectTargets), 7)]}"
        include_path                                = false
        include_query_string                        = false
    }
    # SKU
    sku {
        name        = "${var.AppGatewayMiscConfig["SkuName"]}"
        tier        = "${var.AppGatewayMiscConfig["SkuTier"]}"
        capacity    = "${var.AppGatewayMiscConfig["SkuCapacity"]}"
    }
    # WAF Config
    waf_configuration {
        enabled                     = "${var.AppGatewayWafEnabled}"
        rule_set_type               = "${var.AppGatewayWafConfig["RuleType"]}"
        rule_set_version            = "${var.AppGatewayWafConfig["RuleVersion"]}"
        firewall_mode               = "${var.AppGatewayWafMode}"
        file_upload_limit_mb        = "${var.AppGatewayWafConfig["UploadLimit"]}"
        max_request_body_size_kb    = "${var.AppGatewayWafConfig["MaxRequestBodySize"]}"
    }

    count = "${length(var.Location)}"
}
