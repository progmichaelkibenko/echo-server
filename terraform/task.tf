provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.azurerm_resource_group}"
  location = "${var.location}"
}

resource "azurerm_availability_set" "main" {
  name                         = "${var.vm_name}avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  platform_fault_domain_count  = "${var.vms_num}"
  platform_update_domain_count = "${var.vms_num}"
  managed                      = true
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
  address_prefix       = "10.0.10.0/24"
}

resource "azurerm_public_ip" "main" {
    name                         = "${var.public_ip_name}${count.index}"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"
    allocation_method            = "Static"
    count = "${var.vms_num + 1}"
}

resource "azurerm_lb" "main" {
  resource_group_name = "${azurerm_resource_group.main.name}"
  name                = "${var.vm_name}lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${element(azurerm_public_ip.main.*.id, "${var.vms_num}")}"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name                = "${var.vm_name}BackendPool"
  resource_group_name = "${azurerm_resource_group.main.name}"
  loadbalancer_id     = "${azurerm_lb.main.id}"
}

resource "azurerm_lb_probe" "main" {
 resource_group_name = "${azurerm_resource_group.main.name}"
 loadbalancer_id     = "${azurerm_lb.main.id}"
 name                = "${var.vm_name}running-probe"
 port                = "80"
}

resource "azurerm_lb_rule" "main" {
   resource_group_name            = "${azurerm_resource_group.main.name}"
   loadbalancer_id                = "${azurerm_lb.main.id}"
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = "80"
   backend_port                   = "80"
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.main.id}"
   frontend_ip_configuration_name = "LoadBalancerFrontEnd"
   probe_id                       = "${azurerm_lb_probe.main.id}"
}

resource "azurerm_network_interface" "main" {
  name                      = "${var.vm_name}NIC${count.index}"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
  count = "${var.vms_num}"

  ip_configuration {
    name                          = "nicconfig"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.main.*.id, count.index)}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.main.id}"]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.vm_name}${count.index}"
  location                         = "${azurerm_resource_group.main.location}"
  resource_group_name              = "${azurerm_resource_group.main.name}"
  availability_set_id              = "${azurerm_availability_set.main.id}"
  network_interface_ids            = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  vm_size                          = "${var.vm_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  count = "${var.vms_num}"

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "AZLXDEVOPS01-OS${count.index}"
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
          host = "${element(data.azurerm_public_ip.main.*.ip_address, count.index)}"
          type = "ssh"
          user = "${var.admin_username}"
          password = "${var.admin_password}"
          timeout = "1m"
      }
      inline = [
          "git clone https://github.com/progmichaelkibenko/echo-server.git",
          "cd echo-server",
          "chmod +x echo-server-src/server.py",
          "sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT",
          "sudo nohup python3 echo-server-src/server.py &",
          "sleep 30"
      ]
    }
}

data "azurerm_public_ip" "main" {
  name                = "${var.public_ip_name}${count.index}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  count = "${var.vms_num + 1}"
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.main.*.ip_address}"
}