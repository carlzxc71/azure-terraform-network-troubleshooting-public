// If this data block does not work, you may need to deploy it by changing this to a resource block instead
data "azapi_resource" "network_watcher" {
  type = "Microsoft.Network/networkWatchers@2025-03-01"
  resource_id = provider::azapi::resource_group_resource_id(
    var.azure_subscription_id,
    "NetworkWatcherRG",
    "microsoft.network/networkwatchers",
    ["NetworkWatcher_swedencentral"]
  )
}

resource "azapi_resource" "network_flowlogs_a" {
  type      = "Microsoft.Network/networkWatchers/flowLogs@2025-03-01"
  name      = "${azapi_resource.subnet_a.name}-acm-connection-monitor-lab-flowlog"
  location  = var.location
  parent_id = data.azapi_resource.network_watcher.id
  body = {
    properties = {
      storageId        = azapi_resource.storage_a.id
      targetResourceId = azapi_resource.subnet_a.id
      enabled          = true
      format = {
        type    = "JSON"
        version = 2
      }
      retentionPolicy = {
        days    = 10
        enabled = true
      }
    }
  }
}

resource "azapi_resource" "network_flowlogs_b" {
  type      = "Microsoft.Network/networkWatchers/flowLogs@2025-03-01"
  name      = "${azapi_resource.subnet_b.name}-acm-connection-monitor-lab-flowlog"
  location  = var.location
  parent_id = data.azapi_resource.network_watcher.id
  body = {
    properties = {
      storageId        = azapi_resource.storage_b.id
      targetResourceId = azapi_resource.subnet_b.id
      enabled          = true
      format = {
        type    = "JSON"
        version = 2
      }
      retentionPolicy = {
        days    = 10
        enabled = true
      }
    }
  }
}

resource "azapi_resource" "storage_a" {
  type      = "Microsoft.Storage/storageAccounts@2025-06-01"
  name      = "${var.name_prefix}storagea"
  parent_id = azapi_resource.rg.id
  location  = var.location
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_LRS"
    }
  }
  response_export_values = {}
  retry = {
    error_message_regex = ["StorageAccountOperationInProgress"]
  }
}

resource "azapi_resource" "storage_b" {
  type      = "Microsoft.Storage/storageAccounts@2025-06-01"
  name      = "${var.name_prefix}storageb"
  parent_id = azapi_resource.rg.id
  location  = var.location
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_LRS"
    }
  }
  response_export_values = {}
  retry = {
    error_message_regex = ["StorageAccountOperationInProgress"]
  }
}












// You can uncomment the following resources by selecting them all and CMD + K + U (Or CTRL + K + U on Windows)

# resource "azapi_resource" "connection_monitor" {
#   type      = "Microsoft.Network/networkWatchers/connectionMonitors@2025-03-01"
#   name      = "${var.name_prefix}-connection-monitor"
#   parent_id = data.azapi_resource.network_watcher.id
#   location  = var.location
#   body = {
#     properties = {
#       endpoints = [
#         {
#           name       = "${azapi_resource.vnet_a.name}(acm-connection-monitor-lab)"
#           resourceId = azapi_resource.vnet_a.id
#           type       = "AzureVNet"
#         },
#         {
#           name       = "${azapi_resource.vnet_b.name}(acm-connection-monitor-lab)"
#           resourceId = azapi_resource.vnet_b.id
#           type       = "AzureVNet"
#         }
#       ]
#       testConfigurations = [
#         {
#           name             = "test-tcp-22"
#           testFrequencySec = 30
#           protocol         = "Tcp"
#           successThreshold = {
#             checksFailedPercent = 10
#             roundTripTimeMs     = 50
#           }
#           tcpConfiguration = {
#             port              = 22
#             disableTraceRoute = false
#           }
#         }
#       ]
#       testGroups = [
#         {
#           name    = "conmon-testgroup"
#           disable = false
#           sources = [
#             "${azapi_resource.vnet_a.name}(acm-connection-monitor-lab)"
#           ]
#           destinations = [
#             "${azapi_resource.vnet_b.name}(acm-connection-monitor-lab)"
#           ]
#           testConfigurations = [
#             "test-tcp-22"
#           ]
#         }
#       ]
#       outputs = [
#         {
#           type = "Workspace"
#           workspaceSettings = {
#             workspaceResourceId = azapi_resource.log_analytics.id
#           }
#         }
#       ]
#     }
#   }
#   response_export_values = {}
# }

# resource "azapi_resource" "action_group" {
#   type      = "Microsoft.Insights/actionGroups@2024-10-01-preview"
#   name      = "ag-dev-sc-acm-monitor"
#   parent_id = azapi_resource.rg.id
#   location  = "global"
#   body = {
#     properties = {
#       enabled        = true
#       groupShortName = "acm"
#       emailReceivers = [
#         {
#           emailAddress = var.email_alert_receiver
#           name         = "My Name"
#         }
#       ]
#     }
#   }
# }

# resource "azapi_resource" "metric_alert" {
#   type      = "Microsoft.Insights/metricAlerts@2024-03-01-preview"
#   name      = "acm-connection-monitor"
#   parent_id = azapi_resource.rg.id
#   location  = "global"
#   body = {
#     properties = {
#       actions = [
#         {
#           actionGroupId = azapi_resource.action_group.id
#         },
#       ]
#       autoMitigate = true
#       criteria = {
#         allOf = [
#           {
#             criterionType = "StaticThresholdCriterion"
#             dimensions = [
#               {
#                 name     = "SourceName"
#                 operator = "Include"
#                 values = [
#                   "*",
#                 ]
#               },
#               {
#                 name     = "DestinationName"
#                 operator = "Include"
#                 values = [
#                   "*",
#                 ]
#               },
#               {
#                 name     = "TestGroupName"
#                 operator = "Include"
#                 values = [
#                   "*",
#                 ]
#               },
#               {
#                 name     = "TestConfigurationName"
#                 operator = "Include"
#                 values = [
#                   "*",
#                 ]
#               },
#             ]
#             metricName      = "TestResult"
#             metricNamespace = "Microsoft.Network/networkWatchers/connectionMonitors"
#             name            = "Metric1"
#             operator        = "GreaterThan"
#             threshold       = 1
#             timeAggregation = "Maximum"
#           },
#         ]
#         "odata.type" = "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria"
#       }
#       enabled             = true
#       evaluationFrequency = "PT1M"
#       scopes = [
#         azapi_resource.connection_monitor.id,
#       ]
#       severity             = 1
#       targetResourceRegion = "swedencentral"
#       targetResourceType   = "Microsoft.Network/networkWatchers/connectionMonitors"
#       windowSize           = "PT5M"
#     }
#   }
# }
