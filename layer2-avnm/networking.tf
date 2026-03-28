# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "layer2" {
  name     = "rg-layer2-avnm-${var.environment}"
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------------------------------------
# Hub Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  address_space       = var.hub_vnet_address_space
  tags                = merge(var.tags, { "role" = "hub-network" })
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.layer2.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_firewall_subnet_prefix
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.layer2.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_bastion_subnet_prefix
}

# -----------------------------------------------------------------------------
# Spoke 1 Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  address_space       = var.spoke1_vnet_address_space
  tags                = merge(var.tags, { "avnm-group" = "hub-spoke-layer2" })
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "snet-spoke1-workload"
  resource_group_name  = azurerm_resource_group.layer2.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = var.spoke1_workload_subnet_prefix
}

# -----------------------------------------------------------------------------
# Spoke 2 Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  address_space       = var.spoke2_vnet_address_space
  tags                = merge(var.tags, { "avnm-group" = "hub-spoke-layer2" })
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "snet-spoke2-workload"
  resource_group_name  = azurerm_resource_group.layer2.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = var.spoke2_workload_subnet_prefix
}