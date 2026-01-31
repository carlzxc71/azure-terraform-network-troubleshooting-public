locals {
  nic_a_output = try(jsondecode(azapi_resource.nic_a.output), azapi_resource.nic_a.output)
  nic_b_output = try(jsondecode(azapi_resource.nic_b.output), azapi_resource.nic_b.output)
}

output "resource_group_id" {
  value = azapi_resource.rg.id
}

output "vnet_a_id" {
  value = azapi_resource.vnet_a.id
}

output "vnet_b_id" {
  value = azapi_resource.vnet_b.id
}

output "vnet_hub_id" {
  value = azapi_resource.vnet_hub.id
}

output "azure_firewall_id" {
  value = azapi_resource.azure_firewall.id
}

output "azure_firewall_private_ip" {
  value = azapi_resource.azure_firewall.output.private_ip_address
}

output "log_analytics_workspace_id" {
  value = azapi_resource.log_analytics.id
}