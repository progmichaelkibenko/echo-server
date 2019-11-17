variable "azurerm_resource_group" {
    type = "string"
    default = "packerDemoRessourceGroup"
}

variable "azurerm_image" {
    type = "string"
    default = "EchoServerVMImage"
}

variable "location" {
    type = "string"
    default = "West Europe"
}

variable "virtual_network_name" {
    type = "string"
    default = "EchoServerVirtualNetwork"
}

variable "network_security_group_name" {
    type = "string"
    default = "EchoServerNSG"
}

variable "subnet_name" {
    type = "string"
    default = "EchoServerSubNet"
}

variable "public_ip_name" {
  type = "string"
  default = "echoServerPublicIp"
}

variable "vm_name" {
    type = "string"
    default = "EchoServer"
}

variable "vm_size" {
    type = "string"
    default = "Standard_D2s_v3"
}

variable "admin_username" {
    type = "string"
    default = "progmichaelkibenko"
}

variable "admin_password" {
    type = "string"
    default = "Qwerty!!1234"
}

















