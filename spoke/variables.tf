variable "location" {
  description = "The location/region where the resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "The address space that is used the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "The subnets that are used in the virtual network."
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "public_ip_name" {
  description = "The name of the public IP address."
  type        = string
}

variable "virtual_network_gateway" {
  description = "The configuration of the virtual network gateway."
  type = object({
    name                   = string
    sku                    = string
    type                   = string
    subnet_key             = string
    asn                    = number
  })
}

variable "vpn_connection" {
  description = "The configuration of the VPN connection."
  type = object({
    name                            = string
    shared_key                      = string
    peer_virtual_network_gateway_id = string
    egress_nat_rule_ids             = optional(list(string))
    ingress_nat_rule_ids            = optional(list(string))
  })
}
