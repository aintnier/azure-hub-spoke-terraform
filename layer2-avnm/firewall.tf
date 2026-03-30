# -----------------------------------------------------------------------------
# Azure Firewall - Public IP
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "firewall" {
  name                = "pip-fw-hub-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Azure Firewall Policy
# -----------------------------------------------------------------------------
resource "azurerm_firewall_policy" "hub" {
  name                = "fwpol-hub-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "hub" {
  name               = "rcg-hub-${var.environment}"
  firewall_policy_id = azurerm_firewall_policy.hub.id
  priority           = 100

  network_rule_collection {
    name     = "allow-spoke-to-spoke"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-icmp-spoke1-to-spoke2"
      protocols             = ["ICMP"]
      source_addresses      = var.spoke1_vnet_address_space
      destination_addresses = var.spoke2_vnet_address_space
      destination_ports     = ["*"]
    }

    rule {
      name                  = "allow-icmp-spoke2-to-spoke1"
      protocols             = ["ICMP"]
      source_addresses      = var.spoke2_vnet_address_space
      destination_addresses = var.spoke1_vnet_address_space
      destination_ports     = ["*"]
    }

    rule {
      name                  = "allow-ssh-spoke1-to-spoke2"
      protocols             = ["TCP"]
      source_addresses      = var.spoke1_vnet_address_space
      destination_addresses = var.spoke2_vnet_address_space
      destination_ports     = ["22"]
    }

    rule {
      name                  = "allow-ssh-spoke2-to-spoke1"
      protocols             = ["TCP"]
      source_addresses      = var.spoke2_vnet_address_space
      destination_addresses = var.spoke1_vnet_address_space
      destination_ports     = ["22"]
    }
  }

  network_rule_collection {
    name     = "allow-spoke-to-internet"
    priority = 150
    action   = "Allow"

    rule {
      name                  = "allow-icmp-to-internet"
      protocols             = ["ICMP"]
      source_addresses      = concat(var.spoke1_vnet_address_space, var.spoke2_vnet_address_space)
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }

    rule {
      name                  = "allow-http-https-to-internet"
      protocols             = ["TCP"]
      source_addresses      = concat(var.spoke1_vnet_address_space, var.spoke2_vnet_address_space)
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }
  }

  network_rule_collection {
    name     = "deny-all"
    priority = 200
    action   = "Deny"

    rule {
      name                  = "deny-all-traffic"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

# -----------------------------------------------------------------------------
# Azure Firewall (Standard SKU)
# -----------------------------------------------------------------------------
resource "azurerm_firewall" "hub" {
  name                = "fw-hub-${var.environment}"
  location            = azurerm_resource_group.layer2.location
  resource_group_name = azurerm_resource_group.layer2.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.hub.id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}