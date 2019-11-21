variable "azurerm_resource_group" {
    type = "string"
    default = "packerDemoRessourceGroup"
}

variable "azurerm_image" {
    type = "string"
    default = "EchoServerImage"
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
    default = "Standard_B1ls"
}

variable "admin_username" {
    type = "string"
    default = "progmichaelkibenko"
}

variable "admin_password" {
    type = "string"
    default = "Qwerty!!1234"
}

variable "subscription_id" {
    type = "string"
    default = ""
}

variable "client_id" {
    type = "string"
    default = ""
}

variable "client_secret" {
    type = "string"
    default = ""
}

variable "tenant_id" {
    type = "string"
    default = ""
}

variable "vms_num" {
  type = "string"
  default = "2"
}



















