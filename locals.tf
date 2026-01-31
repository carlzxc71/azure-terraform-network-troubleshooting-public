locals {
  api = {
    resource_groups = "Microsoft.Resources/resourceGroups@2025-04-01"

    virtual_networks        = "Microsoft.Network/virtualNetworks@2025-01-01"
    subnets                 = "Microsoft.Network/virtualNetworks/subnets@2025-01-01"
    network_interfaces      = "Microsoft.Network/networkInterfaces@2025-01-01"
    network_security_groups = "Microsoft.Network/networkSecurityGroups@2024-10-01"
    vnet_peerings           = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-10-01"

    public_ip_addresses                    = "Microsoft.Network/publicIPAddresses@2025-01-01"
    route_tables                           = "Microsoft.Network/routeTables@2025-01-01"
    azure_firewalls                        = "Microsoft.Network/azureFirewalls@2025-01-01"
    firewall_policies                      = "Microsoft.Network/firewallPolicies@2025-01-01"
    firewall_policy_rule_collection_groups = "Microsoft.Network/firewallPolicies/ruleCollectionGroups@2025-01-01"

    virtual_machines = "Microsoft.Compute/virtualMachines@2025-04-01"

    log_analytics_workspaces = "Microsoft.OperationalInsights/workspaces@2025-07-01"
    diagnostic_settings      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  }

  names = {
    vnet_a   = "${var.name_prefix}-vnet-a"
    vnet_b   = "${var.name_prefix}-vnet-b"
    vnet_hub = "${var.name_prefix}-vnet-hub"
    subnet_a = "${var.name_prefix}-subnet-a"
    subnet_b = "${var.name_prefix}-subnet-b"

    azure_firewall_subnet            = "AzureFirewallSubnet"
    azure_firewall_management_subnet = "AzureFirewallManagementSubnet"
    nsg_a                            = "${var.name_prefix}-nsg-a"
    nsg_b                            = "${var.name_prefix}-nsg-b"
    nic_a                            = "${var.name_prefix}-nic-a"
    nic_b                            = "${var.name_prefix}-nic-b"
    vm_a                             = "${var.name_prefix}-vm-a"
    vm_b                             = "${var.name_prefix}-vm-b"

    azfw_pip      = "${var.name_prefix}-azfw-pip"
    azfw_mgmt_pip = "${var.name_prefix}-azfw-mgmt-pip"
    azfw_policy   = "${var.name_prefix}-azfw-policy"
    azfw          = "${var.name_prefix}-azfw"

    rt_a = "${var.name_prefix}-rt-a"
    rt_b = "${var.name_prefix}-rt-b"

    law       = "${var.name_prefix}-law"
    azfw_diag = "${var.name_prefix}-azfw-diag"
  }
}
