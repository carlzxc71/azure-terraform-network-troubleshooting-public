resource "azapi_resource" "vnet_hub" {
  type      = local.api.virtual_networks
  name      = local.names.vnet_hub
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      addressSpace = {
        addressPrefixes = [var.vnet_hub_cidr]
      }
    }
  }
}

resource "azapi_resource" "subnet_azure_firewall" {
  type      = local.api.subnets
  name      = local.names.azure_firewall_subnet
  parent_id = azapi_resource.vnet_hub.id

  body = {
    properties = {
      addressPrefix = var.azure_firewall_subnet_cidr
    }
  }
  retry = {
    error_message_regex = ["AnotherOperationInProgress"]
  }
}

resource "azapi_resource" "subnet_azure_firewall_management" {
  type      = local.api.subnets
  name      = local.names.azure_firewall_management_subnet
  parent_id = azapi_resource.vnet_hub.id

  body = {
    properties = {
      addressPrefix = var.azure_firewall_management_subnet_cidr
    }
  }
}

resource "azapi_resource" "azfw_pip" {
  type      = local.api.public_ip_addresses
  name      = local.names.azfw_pip
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIPAllocationMethod = "Static"
      publicIPAddressVersion   = "IPv4"
    }
  }
}

resource "azapi_resource" "azfw_mgmt_pip" {
  type      = local.api.public_ip_addresses
  name      = local.names.azfw_mgmt_pip
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIPAllocationMethod = "Static"
      publicIPAddressVersion   = "IPv4"
    }
  }
}

resource "azapi_resource" "azfw_policy" {
  type      = local.api.firewall_policies
  name      = local.names.azfw_policy
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      sku = {
        tier = "Basic"
      }
    }
  }
}

resource "azapi_resource" "azfw_policy_rcg" {
  type      = local.api.firewall_policy_rule_collection_groups
  name      = "default"
  parent_id = azapi_resource.azfw_policy.id

  body = {
    properties = {
      priority = 100
      ruleCollections = [
        {
          name               = "allow-egress-general"
          ruleCollectionType = "FirewallPolicyFilterRuleCollection"
          priority           = 100
          action = {
            type = "Allow"
          }
          rules = [
            {
              name                 = "allow-dns"
              ruleType             = "NetworkRule"
              ipProtocols          = ["TCP", "UDP"]
              sourceAddresses      = ["*"]
              destinationAddresses = ["*"]
              destinationPorts     = ["53"]
            },
            {
              name                 = "allow-web"
              ruleType             = "NetworkRule"
              ipProtocols          = ["TCP"]
              sourceAddresses      = ["*"]
              destinationAddresses = ["*"]
              destinationPorts     = ["80", "443"]
            }
          ]
        }
      ]
    }
  }
  schema_validation_enabled = false
}

resource "azapi_resource" "azure_firewall" {
  type      = local.api.azure_firewalls
  name      = local.names.azfw
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      sku = {
        name = "AZFW_VNet"
        tier = "Basic"
      }
      firewallPolicy = {
        id = azapi_resource.azfw_policy.id
      }
      managementIpConfiguration = {
        name = "mgmt-ipconfig"
        properties = {
          subnet = {
            id = azapi_resource.subnet_azure_firewall_management.id
          }
          publicIPAddress = {
            id = azapi_resource.azfw_mgmt_pip.id
          }
        }
      }
      ipConfigurations = [
        {
          name = "ipconfig"
          properties = {
            subnet = {
              id = azapi_resource.subnet_azure_firewall.id
            }
            publicIPAddress = {
              id = azapi_resource.azfw_pip.id
            }
          }
        }
      ]
    }
  }

  response_export_values = {
    private_ip_address = "properties.ipConfigurations[0].properties.privateIPAddress"
  }
}

resource "azapi_resource" "log_analytics" {
  type      = local.api.log_analytics_workspaces
  name      = local.names.law
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
      retentionInDays = 30
    }
  }
}

resource "azapi_resource" "azfw_diagnostic" {
  type      = local.api.diagnostic_settings
  name      = local.names.azfw_diag
  parent_id = azapi_resource.azure_firewall.id

  body = {
    properties = {
      workspaceId                 = azapi_resource.log_analytics.id
      logAnalyticsDestinationType = "Dedicated"
      logs = [
        {
          categoryGroup = "allLogs"
          enabled       = true
        }
      ]
    }
  }
}
