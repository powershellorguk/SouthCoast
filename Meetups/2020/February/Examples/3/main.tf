provider "azurerm" {
	version = "= 1.44.0"
}

resource "azurerm_resource_group" "rg" {
    name        = "RG-${var.BaseName}"
    location    = var.Region
    tags        = var.Tags
}

resource "azurerm_virtual_network" "vnet" {
    name                = "VNET-${var.BaseName}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = var.Region
    address_space       = ["10.21.0.0/16"]
    tags                = var.Tags
}

resource "azurerm_subnet" "subnet" {
    name                    = "SNET-${var.BaseName}"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefix          = "10.21.1.0/24"
}

resource "azurerm_network_interface" "nic" {
    name                = "NIC-${var.BaseName}"
    location            = var.Region
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                            = "IP-${var.BaseName}"
        subnet_id                       = azurerm_subnet.subnet.id
        private_ip_address_allocation   = "Dynamic"
    }
    
    tags                = var.Tags
}

resource "azurerm_virtual_machine" "vm" {
    name                    = "VM-${var.BaseName}"
    resource_group_name     = azurerm_resource_group.rg.name
    location                = var.Region
    network_interface_ids   = [azurerm_network_interface.nic.id]
    vm_size                 = "Basic_A0"

    os_profile_linux_config {
        disable_password_authentication = false
    }

    os_profile {
        computer_name   = var.BaseName
        admin_username  = "tf-admin"
        admin_password  = "PSUG-Demo-Secret-2020!"
    }

    storage_os_disk {
        name                = "VHD-${var.BaseName}"
        create_option       = "FromImage"
        managed_disk_type   = "Standard_LRS"
    }

    storage_image_reference {
        publisher   = "Canonical"
        offer       = "UbuntuServer"
        sku         = "18.04-LTS"
        version     = "Latest"
    }

    tags                                = var.Tags
    delete_os_disk_on_termination       = true
    delete_data_disks_on_termination    = true
}

