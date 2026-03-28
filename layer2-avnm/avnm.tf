# -----------------------------------------------------------------------------
# Azure Virtual Network Manager (AVNM)
# -----------------------------------------------------------------------------
data "azurerm_subscription" "current" {}

resource "azurerm_network_manager" "avnm" {
  name                = "avnm-hubspoke-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  scope_accesses      = ["Connectivity", "SecurityAdmin"]
  description         = "Network Manager for Hub and Spoke VNet topology"
  tags                = var.tags

  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
}

# -----------------------------------------------------------------------------
# Network Group - Spokes
# -----------------------------------------------------------------------------
resource "azurerm_network_manager_network_group" "spokes" {
  name               = "ng-spokes-${var.environment}"
  network_manager_id = azurerm_network_manager.avnm.id
  description        = "Network Group containing all Spoke VNets"
}

# -----------------------------------------------------------------------------
# Connectivity Configuration
# -----------------------------------------------------------------------------
resource "azurerm_network_manager_connectivity_configuration" "hub_and_spoke" {
  name                  = "cc-hubandspoke-${var.environment}"
  network_manager_id    = azurerm_network_manager.avnm.id
  connectivity_topology = "HubAndSpoke"

  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.spokes.id
    use_hub_gateway    = false
  }

  hub {
    resource_id   = azurerm_virtual_network.hub.id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
}

# -----------------------------------------------------------------------------
# AVNM Deployment
# -----------------------------------------------------------------------------
resource "azurerm_network_manager_deployment" "connectivity" {
  network_manager_id = azurerm_network_manager.avnm.id
  location           = azurerm_resource_group.layer2.location
  scope_access       = "Connectivity"
  configuration_ids  = [azurerm_network_manager_connectivity_configuration.hub_and_spoke.id]

  triggers = {
    configuration_ids = join(",", [azurerm_network_manager_connectivity_configuration.hub_and_spoke.id])
    force_update      = "1"
  }
}