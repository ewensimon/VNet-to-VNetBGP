module "vpn_outside" {
  source = "./spoke"

  location             = "westeurope"
  resource_group_name  = "outside-vpn"
  virtual_network_name = "outside-vnet"
  address_space        = ["10.0.1.0/24"]

  subnets = {
    "gateway" = {
      name             = "GatewaySubnet"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
  public_ip_name = "outside-vpn-pip"
  virtual_network_gateway = {
    name       = "outside-gw"
    sku        = "VpnGw2AZ"
    type       = "Vpn"
    subnet_key = "gateway"
    asn        = 200
  }
  vpn_connection = {
    name                            = "outside-connection"
    shared_key                      = "abc123abc123"
    peer_virtual_network_gateway_id = module.vpn_apt.virtual_network_gateway_id
    egress_nat_rule_ids             = [azurerm_virtual_network_gateway_nat_rule.outside.id]
  }
}

module "linuxvmoutside" {
  source = "./linuxvm"

  location       = "westeurope"
  prefix         = "linuxvm-outside"
  address_space  = ["100.0.0.0/24"]
  admin_username = "adminuser"
  admin_password = "P@$$w0rd1234!"
}

resource "azurerm_virtual_network_peering" "outside_linux" {
  name                      = "outside-to-linux"
  resource_group_name       = module.vpn_outside.virtual_network.resource_group_name
  virtual_network_name      = module.vpn_outside.virtual_network.name
  remote_virtual_network_id = module.linuxvmoutside.virtual_network.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "linux_outside" {
  name                      = "linux-to-outside"
  resource_group_name       = module.linuxvmoutside.virtual_network.resource_group_name
  virtual_network_name      = module.linuxvmoutside.virtual_network.name
  remote_virtual_network_id = module.vpn_outside.virtual_network.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_gateway_nat_rule" "outside" {
  name                       = "outside-vpngatewaynatrule"
  resource_group_name        = module.vpn_outside.resource_group_name
  virtual_network_gateway_id = module.vpn_outside.virtual_network_gateway_id

  external_mapping {
    address_space = "192.168.1.0/26"
  }

  internal_mapping {
    address_space = "100.0.0.0/26"
  }
}

resource "azurerm_monitor_diagnostic_setting" "outside" {
  name                       = "diag-outside"
  target_resource_id         = module.vpn_outside.virtual_network_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  enabled_log {
    category = "TunnelDiagnosticLog"
  }

  enabled_log {
    category = "RouteDiagnosticLog"
  }

  enabled_log {
    category = "IKEDiagnosticLog"
  }

  enabled_log {
    category = "P2SDiagnosticLog"
  }

  metric {
    category = "AllMetrics"
  }
}
