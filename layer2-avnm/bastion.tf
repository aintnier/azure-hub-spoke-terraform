# -----------------------------------------------------------------------------
# Azure Bastion — Public IP
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-hub-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Azure Bastion Host (Basic SKU)
# -----------------------------------------------------------------------------
resource "azurerm_bastion_host" "hub" {
  name                = "bas-hub-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  sku                 = "Basic"
  tags                = var.tags

  ip_configuration {
    name                 = "bas-ipconfig"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}