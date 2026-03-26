# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "layer1" {
  name     = "rg-layer1-manual-peering-${var.environment}"
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------------------------------------
# Hub Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  location            = azurerm_resource_group.layer1.location
  resource_group_name = azurerm_resource_group.layer1.name
  address_space       = var.hub_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.layer1.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_firewall_subnet_prefix
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.layer1.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_bastion_subnet_prefix
}

# -----------------------------------------------------------------------------
# Spoke 1 Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1-${var.environment}"
  location            = azurerm_resource_group.layer1.location
  resource_group_name = azurerm_resource_group.layer1.name
  address_space       = var.spoke1_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "snet-spoke1-workload"
  resource_group_name  = azurerm_resource_group.layer1.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = var.spoke1_workload_subnet_prefix
}

# -----------------------------------------------------------------------------
# Spoke 2 Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2-${var.environment}"
  location            = azurerm_resource_group.layer1.location
  resource_group_name = azurerm_resource_group.layer1.name
  address_space       = var.spoke2_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "snet-spoke2-workload"
  resource_group_name  = azurerm_resource_group.layer1.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = var.spoke2_workload_subnet_prefix
}

# -----------------------------------------------------------------------------
# VNet Peering: Hub <-> Spoke 1
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.layer1.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.layer1.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# -----------------------------------------------------------------------------
# VNet Peering: Hub <-> Spoke 2
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                         = "peer-hub-to-spoke2"
  resource_group_name          = azurerm_resource_group.layer1.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                         = "peer-spoke2-to-hub"
  resource_group_name          = azurerm_resource_group.layer1.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}
