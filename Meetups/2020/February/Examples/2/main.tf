provider "azurerm" {
	version = "= 1.44.0"
}

resource "azurerm_resource_group" "rg" {
	name		= "RG-TerraformTest"
	location	= "uksouth"
}

# resource "azurerm_storage_account" "sa" {
# 	name						= "faef0c50024249088649ef85"
# 	resource_group_name			= "RG-TerraformTest"
# 	location					= "uksouth"
# 	account_kind				= "StorageV2"
# 	account_tier				= "Standard"
# 	account_replication_type	= "LRS"
# 	enable_https_traffic_only	= true
# 	blob_properties {
# 		delete_retention_policy {
# 			days				= 7
# 		}
# 	}
# }

# resource "azurerm_storage_container" "sc" {
# 	name					= "demo-container"
# 	storage_account_name	= "faef0c50024249088649ef85"
# 	container_access_type	= "private"
# }

# resource "azurerm_storage_blob" "blobs" {
# 	name					= "Blob-${count.index + 1}.txt"
# 	storage_account_name	= "faef0c50024249088649ef85"
# 	storage_container_name	= "demo-container"
# 	type					= "Block"
# 	access_tier				= "Hot"
# 	source					= "${path.root}/File${count.index + 1}.txt"
# 	count					= 2
# }
