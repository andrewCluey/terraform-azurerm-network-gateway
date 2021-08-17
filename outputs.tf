


output "vnet_gw_id" {
  description = "The ID of the vNet Gateway."
  value       = azurerm_virtual_network_gateway.gw.id
}

output "vnet_gw_settings" {
  description = "All settings relating to the new vNET Gateway."
  value       = azurerm_virtual_network_gateway.gw
}

output "local_gw_settings" {
  description = "All settings relating to the new Local gateway"
  value       = azurerm_local_network_gateway.local_gw
}

output "local_gw_id" {
  description = "The ID of the local Gateway."
  value       = azurerm_local_network_gateway.local_gw.id
}


output "gw_public_ipaddress" {
  description = "The Public IP address assigned to the vNet Gateway."
  value       = azurerm_public_ip.gw_pip.ip_address
}

output "gw_fqdn" {
  description = "The FQDN assigned to the vNet Gateway."
  value       = azurerm_public_ip.gw_pip.fqdn
}

