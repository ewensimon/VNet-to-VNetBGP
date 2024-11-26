
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  zones = [
    "1",
    "2",
    "3"
  ]
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = var.virtual_network_gateway.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku  = var.virtual_network_gateway.sku
  type = var.virtual_network_gateway.type

  enable_bgp                            = true
  private_ip_address_enabled            = false
  bgp_route_translation_for_nat_enabled = true

  bgp_settings {
    asn = var.virtual_network_gateway.asn
  }

  ip_configuration {
    name                 = "ipconfig"
    public_ip_address_id = azurerm_public_ip.this.id
    subnet_id            = azurerm_subnet.this[var.virtual_network_gateway.subnet_key].id
  }
}

resource "azurerm_virtual_network_gateway_connection" "this" {
  name                = var.vpn_connection.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.this.id
  peer_virtual_network_gateway_id = var.vpn_connection.peer_virtual_network_gateway_id

  enable_bgp                     = true
  local_azure_ip_address_enabled = false

  shared_key = var.vpn_connection.shared_key

  egress_nat_rule_ids  = var.vpn_connection.egress_nat_rule_ids
  ingress_nat_rule_ids = var.vpn_connection.ingress_nat_rule_ids

  dpd_timeout_seconds = 45
}
