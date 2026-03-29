# -----------------------------------------------------------------------------
# Azure Virtual WAN + Virtual Hub
# -----------------------------------------------------------------------------
resource "azurerm_virtual_wan" "main" {
  name                              = "vwan-hubspoke-${var.environment}"
  location                          = azurerm_resource_group.layer3.location
  resource_group_name               = azurerm_resource_group.layer3.name
  type                              = var.virtual_wan_type
  office365_local_breakout_category = "None"
  tags                              = var.tags
}

resource "azurerm_virtual_hub" "hub" {
  name                = "vhub-hubspoke-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_prefix      = var.virtual_hub_address_prefix
  sku                 = "Standard"
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Virtual Hub Connections (Spokes + Bastion VNet)
# -----------------------------------------------------------------------------
resource "azurerm_virtual_hub_connection" "spoke1" {
  name                      = "conn-vhub-spoke1-${var.environment}"
  virtual_hub_id            = azurerm_virtual_hub.hub.id
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
  internet_security_enabled = true
}

resource "azurerm_virtual_hub_connection" "spoke2" {
  name                      = "conn-vhub-spoke2-${var.environment}"
  virtual_hub_id            = azurerm_virtual_hub.hub.id
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
  internet_security_enabled = true
}

resource "azurerm_virtual_hub_connection" "bastion" {
  name                      = "conn-vhub-bastion-${var.environment}"
  virtual_hub_id            = azurerm_virtual_hub.hub.id
  remote_virtual_network_id = azurerm_virtual_network.bastion.id
  internet_security_enabled = false
}