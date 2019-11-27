#Log analytics
logAnalyticsRetention               = "30"
logAnalyticsSku                     = "pergb2018"

# General
BaseName                            = "PSUGDemo"
Environment                         = "NonProd"
Tags                                = {
    costcode                        = "will"
    environment                     = "temporary"
    product                         = "demo"
}

# WebApp
PlanSettings                        = {
    Kind                            = "Windows"
    Tier                            = "Standard"
    Size                            = "S1"
    Capacity                        = 2
}

# Web App Slots
appslot                             ={
    Primary                         = "main"
    Secondary                       = "secondary"
}

# IP Whitelists
# Home [81.107.192.113/32], Southampton [x.x.x.x/32]
WhitelistIpsInternal                = ["81.107.192.113/32"]

# Traffic Manager IPs (Used for Health Probes https://azuretrafficmanagerdata.blob.core.windows.net/probes/azure/probe-ip-ranges.json) [40.68.30.66/32 > 104.42.192.195/32], CMS Master - Possible Outbound IPs for Slot [x.x.x.x/32 > y.y.y.y/32] 
WhitelistIpsAzure                   = ["40.68.30.66/32","40.68.31.178/32","137.135.80.149/32","137.135.82.249/32","23.96.236.252/32","65.52.217.19/32","40.87.147.10/32","40.87.151.34/32","13.75.124.254/32","13.75.127.63/32","52.172.155.168/32","52.172.158.37/32","104.215.91.84/32","13.75.153.124/32","13.84.222.37/32","23.101.191.199/32","23.96.213.12/32","137.135.46.163/32","137.135.47.215/32","191.232.208.52/32","191.232.214.62/32","13.75.152.253/32","104.41.187.209/32","104.41.190.203/32","52.173.90.107/32","52.173.250.232/32","104.45.149.110/32","40.114.5.197/32","52.240.151.125/32","52.240.144.45/32","13.65.95.152/32","13.65.92.252/32","40.78.67.110/32","104.42.192.195/32"]

ExternalWhitelisting                = "Yes"
# DataDog Synthetics - [19 total IPs]
WhitelistIpsExternal                = {
    DataDog-Synthetics              = ["13.114.211.96/32","13.115.46.213/32","13.238.14.57/32","13.54.169.48/32","18.130.113.168/32","18.195.155.52/32","3.120.223.25/32","3.121.24.234/32","3.18.172.189/32","3.18.188.104/32","3.18.197.0/32","34.208.32.189/32","35.176.195.46/32","35.177.43.250/32","52.192.175.207/32","52.35.61.232/32","52.60.189.53/32","52.89.221.151/32","99.79.87.237/32"]
}

# CMS Master
CustomDomain                        = {
    Primary                         = "master-demo.mydomain.com"
    Secondary                       = "master-demo-slot.mydomain.com"
}

# SQL
#Client DB Name Suffix
clientDBName                        = ["main","secondary"]

# StorageAccount
StorageContainerName                = "images"
StorageContainerType                = "blob"
StorageAccountEnvironments          = ["main","secondary"]
StorageQueueNames                   = ["one","two"]
CdnProfile                          = "Standard_Microsoft"

# AppGateway
VnetAddressSpace                    = ["10.21.35.0/27","10.21.35.32/27"]
SubnetAddressPrefix                 = ["10.21.35.0/28","10.21.35.32/28"]
ApplicationTrafficPermittedTag      = "None"
AppGatewayWafMode                   = "Detection"
AppGatewayWafEnabled                = "true"
SslPolicy                           = "AppGwSslPolicy20170401S"
AppGatewayConfig                    = {
    Cookies                         = "Enabled"
    Port                            = "443"
    Protocol                        = "Https"
    Timeout                         = "90"
}
WebsiteUrls                         = {
    site-a                          = "site-a.mydomain.com"
    site-b                          = "site-b.mydomain.com"
    site-c                          = "site-c.mydomain.com"
    site-d                          = "site-d.mydomain.com"
}
WebsiteSlotUrls                     = {
    site-a                          = "site-a-slot.mydomain.com"
    site-b                          = "site-b-slot.mydomain.com"
    site-c                          = "site-c-slot.mydomain.com"
    site-d                          = "site-d-slot.mydomain.com"
}
RedirectUrls                        = {
    site-a                          = "www.site-a.mydomain.com"
    site-b                          = "www.site-b.mydomain.com"
    site-c                          = "www.site-c.mydomain.com"
    site-d                          = "www.site-d.mydomain.com"
}
RedirectType                        = "Permanent"
DdosPlanId                          = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxxxx/providers/Microsoft.Network/ddosProtectionPlans/xxxxxxxxx"
