# -----------------------------------------------------------------------------
# Routing Intent (vWAN managed routing)
# -----------------------------------------------------------------------------
resource "azurerm_virtual_hub_routing_intent" "hub" {
  name           = "ri-vhub-${var.environment}"
  virtual_hub_id = azurerm_virtual_hub.hub.id

  routing_policy {
    name         = "private-traffic-to-firewall"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_firewall.hub.id
  }

  routing_policy {
    name         = "internet-traffic-to-firewall"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.hub.id
  }
}
