# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "layer3" {
  name     = "rg-layer3-vwan-${var.environment}"
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------------------------------------
# Spoke 1 Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  address_space       = var.spoke1_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "snet-spoke1-workload"
  resource_group_name  = azurerm_resource_group.layer3.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = var.spoke1_workload_subnet_prefix
}

# -----------------------------------------------------------------------------
# Spoke 2 Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  address_space       = var.spoke2_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "snet-spoke2-workload"
  resource_group_name  = azurerm_resource_group.layer3.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = var.spoke2_workload_subnet_prefix
}

# -----------------------------------------------------------------------------
# Dedicated Bastion VNet
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "bastion" {
  name                = "vnet-bastion-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  address_space       = var.bastion_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.layer3.name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = var.bastion_subnet_prefix
}