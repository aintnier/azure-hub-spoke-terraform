# -----------------------------------------------------------------------------
# Azure Policy for AVNM Dynamic Membership
# -----------------------------------------------------------------------------

resource "azurerm_policy_definition" "avnm_spokes" {
  name         = "policy-avnm-spokes-${var.environment}"
  policy_type  = "Custom"
  mode         = "Microsoft.Network.Data"
  display_name = "AVNM Dynamic Spoke Membership policy"
  description  = "Automatically adds VNets with tag avnm-group=hub-spoke-layer2 to the AVNM network group."

  metadata = <<METADATA
    {
      "category": "Network"
    }
  METADATA

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Network/virtualNetworks"
        },
        {
          "field": "tags['avnm-group']",
          "equals": "hub-spoke-layer2"
        },
        {
          "field": "tags['environment']",
          "equals": "${var.environment}"
        }
      ]
    },
    "then": {
      "effect": "addToNetworkGroup",
      "details": {
        "networkGroupId": "${azurerm_network_manager_network_group.spokes.id}"
      }
    }
  }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "avnm_spokes_assignment" {
  name                 = "assign-avnm-spokes"
  policy_definition_id = azurerm_policy_definition.avnm_spokes.id
  subscription_id      = data.azurerm_subscription.current.id
  description          = "Assigns the AVNM dynamic membership policy to the current subscription."
}
