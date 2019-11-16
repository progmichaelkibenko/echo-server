provider "azurerm" {
    subscription_id = ""
    client_id       = ""
    client_secret   = ""
    tenant_id       = ""
}

resource "azurerm_resource_group" "main" {
  name     = "${var.azurerm_resource_group}"
  location = "${var.location}"
}

data "azurerm_image" "search" {
  name                = "${var.azurerm_image}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.network_security_group_name}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "SSH"
    description                = "Allow SSH access"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    description                = "Allow HTTPS access"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    description                = "Allow HTTP access"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "PORT 30000"
    description                = "Allow PORT 30000 access"
    priority                   = 360
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "PORT 30000"
    description                = "Allow PORT 30000 access"
    priority                   = 360
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.virtual_network_name}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "internal" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "main" {
    name                         = "${var.public_ip_name}"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"
    allocation_method            = "Static"
}

resource "azurerm_network_interface" "main" {
  name                      = "NIC"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "nicconfig"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

data "azurerm_public_ip" "main" {
  name                = "${var.public_ip_name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

data "azurerm_network_interface" "main" {
  name                = "NIC"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.main.ip_address}"
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.vm_name}"
  location                         = "${azurerm_resource_group.main.location}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "${var.vm_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "AZLXDEVOPS01-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
      connection {
          host = "${data.azurerm_public_ip.main.ip_address}"
          type = "ssh"
          user = "${var.admin_username}"
          password = "${var.admin_password}"
          timeout = "1m"
      }
      inline = [
          "sudo git clone https://github.com/progmichaelkibenko/echo-server.git",
          "sudo minikube start",
          "sudo kubectl apply -f ./echo-server/echo-server-src/k8s"
      ]
    }
}





