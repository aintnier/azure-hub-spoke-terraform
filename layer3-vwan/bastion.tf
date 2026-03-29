# -----------------------------------------------------------------------------
# Azure Bastion — Public IP
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-vwan-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# NSG for AzureBastionSubnet
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  tags                = var.tags

  security_rule {
    name                       = "AllowGatewayManagerInbound443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternetInbound443"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound443"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVirtualNetworkOutbound22And3389"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureCloudOutbound443"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

# -----------------------------------------------------------------------------
# Azure Bastion Host (Standard SKU)
# -----------------------------------------------------------------------------
resource "azurerm_bastion_host" "hub" {
  name                = "bas-vwan-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  sku                 = "Standard"
  ip_connect_enabled  = true
  tags                = var.tags

  ip_configuration {
    name                 = "bas-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.bastion]
}