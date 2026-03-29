# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
output "virtual_wan_id" {
  description = "Resource ID of the Azure Virtual WAN"
  value       = azurerm_virtual_wan.main.id
}

output "virtual_hub_id" {
  description = "Resource ID of the Virtual Hub"
  value       = azurerm_virtual_hub.hub.id
}

output "spoke1_vnet_id" {
  description = "Resource ID of Spoke 1 VNet"
  value       = azurerm_virtual_network.spoke1.id
}

output "spoke2_vnet_id" {
  description = "Resource ID of Spoke 2 VNet"
  value       = azurerm_virtual_network.spoke2.id
}

output "bastion_vnet_id" {
  description = "Resource ID of the dedicated Bastion VNet"
  value       = azurerm_virtual_network.bastion.id
}

# -----------------------------------------------------------------------------
# vWAN Connections
# -----------------------------------------------------------------------------
output "spoke1_vhub_connection_id" {
  description = "Resource ID of Spoke 1 Virtual Hub connection"
  value       = azurerm_virtual_hub_connection.spoke1.id
}

output "spoke2_vhub_connection_id" {
  description = "Resource ID of Spoke 2 Virtual Hub connection"
  value       = azurerm_virtual_hub_connection.spoke2.id
}

output "bastion_vhub_connection_id" {
  description = "Resource ID of Bastion VNet Virtual Hub connection"
  value       = azurerm_virtual_hub_connection.bastion.id
}

# -----------------------------------------------------------------------------
# Firewall
# -----------------------------------------------------------------------------
output "firewall_id" {
  description = "Resource ID of the Azure Firewall in the Virtual Hub"
  value       = azurerm_firewall.hub.id
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall in the Virtual Hub"
  value       = azurerm_firewall.hub.virtual_hub[0].private_ip_address
}

output "firewall_public_ips" {
  description = "Public IP addresses assigned to the Azure Firewall in the Virtual Hub"
  value       = azurerm_firewall.hub.virtual_hub[0].public_ip_addresses
}

# -----------------------------------------------------------------------------
# Routing
# -----------------------------------------------------------------------------
output "routing_intent_id" {
  description = "Resource ID of the Virtual Hub Routing Intent"
  value       = azurerm_virtual_hub_routing_intent.hub.id
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

# -----------------------------------------------------------------------------
# Bastion
# -----------------------------------------------------------------------------
output "bastion_name" {
  description = "Name of the Azure Bastion host (use in Azure Portal to SSH into VMs)"
  value       = azurerm_bastion_host.hub.name
}