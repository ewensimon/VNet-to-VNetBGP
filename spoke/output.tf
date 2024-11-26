output "virtual_network_gateway_id" {
  description = "The ID of the virtual network gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "virtual_network" {
  description = "The virtual network."
  value       = azurerm_virtual_network.this
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}