# -----------------------------------------------------------------------------
# Log Analytics Workspace
# -----------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "hub" {
  name                = "law-hub-${var.environment}"
  location            = azurerm_resource_group.layer3.location
  resource_group_name = azurerm_resource_group.layer3.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Diagnostic Settings — Azure Firewall Logs
# -----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "diag-fw-hub-${var.environment}"
  target_resource_id         = azurerm_firewall.hub.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}