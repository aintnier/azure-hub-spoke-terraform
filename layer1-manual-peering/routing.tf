# -----------------------------------------------------------------------------
# Route Table — Spoke 1
# -----------------------------------------------------------------------------
resource "azurerm_route_table" "spoke1" {
  name                          = "rt-spoke1-${var.environment}"
  location                      = azurerm_resource_group.layer1.location
  resource_group_name           = azurerm_resource_group.layer1.name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = "route-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = azurerm_route_table.spoke1.id
}

# -----------------------------------------------------------------------------
# Route Table — Spoke 2
# -----------------------------------------------------------------------------
resource "azurerm_route_table" "spoke2" {
  name                          = "rt-spoke2-${var.environment}"
  location                      = azurerm_resource_group.layer1.location
  resource_group_name           = azurerm_resource_group.layer1.name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = "route-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = azurerm_route_table.spoke2.id
}
