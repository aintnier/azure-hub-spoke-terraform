# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
output "hub_vnet_id" {
  description = "Resource ID of the Hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "spoke1_vnet_id" {
  description = "Resource ID of Spoke 1 VNet"
  value       = azurerm_virtual_network.spoke1.id
}

output "spoke2_vnet_id" {
  description = "Resource ID of Spoke 2 VNet"
  value       = azurerm_virtual_network.spoke2.id
}

# -----------------------------------------------------------------------------
# Firewall
# -----------------------------------------------------------------------------
output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall"
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP address of the Azure Firewall"
  value       = azurerm_public_ip.firewall.ip_address
}

# -----------------------------------------------------------------------------
# Compute
# -----------------------------------------------------------------------------
output "spoke1_vm_private_ip" {
  description = "Private IP address of the Spoke 1 test VM"
  value       = azurerm_network_interface.spoke1_vm.private_ip_address
}

output "spoke2_vm_private_ip" {
  description = "Private IP address of the Spoke 2 test VM"
  value       = azurerm_network_interface.spoke2_vm.private_ip_address
}

# -----------------------------------------------------------------------------
# Monitoring
# -----------------------------------------------------------------------------
output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.hub.id
}
