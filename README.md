## What this repo deploys

- Resource Group
- VNet A + Subnet A
- VNet B + Subnet B
- Hub VNet + `AzureFirewallSubnet`
- NSG on each spoke subnet with an explicit **deny all inbound** rule (outbound left as Azure defaults)
- 2 Linux VMs (one per subnet) with a generated admin password
- Azure Firewall **Basic** + Firewall Policy (Basic)
- Route tables on Subnet A/B forcing `0.0.0.0/0` + RFC1918 supernets via Azure Firewall
- Log Analytics workspace + diagnostic settings for Azure Firewall (`allLogs`)
- Bidirectional VNet peering (A<->Hub and B<->Hub)
- Azure connection monitor resource
- Virtual network flow log configuration
- Storage accounts for VNET flow logs
- Metric alert and action group

## Read before you deploy!

- Azure Firewall uses a Public IP for dataplane (This will incur some costs even if you deallocate the Firewall, see section on saving money).
- Log ingestion does incur some cost as well.
- Inbound is denied at subnet NSGs (including from peered VNets). This is intentional for Connection Monitor testing.
- `monitoring.tf` has resources that are intentionally disabled; deploy Connection Monitor separately once its time (See video).
- Commands for deallocating both FW and virtual machines are provided further down in this guide.
- Whilst I provide some helpful tips for saving on money/credits when running this lab I do not take any responsibility for the costs you incur running this lab. If you forget to deallocate resources or do other things with the lab then was intended; its on you :) 

## Run

Prereqs:

- Terraform and Azure CLI installed
- Logged into Azure CLI (`az login`) and set to the right subscription `az account set -s -your-sub-id` 
- Update `variables.tf` and the variable called `azure_subscription_id` with your Azure Subscription ID

Commands:

- `terraform init`
- `terraform fmt -recursive`
- `terraform validate`
- `terraform plan`
- `terraform apply -auto-approve`

To remove (When you're done):

- `terraform destroy -auto-approve`

## Save on money tip

If you’re stepping away and don’t want resources running and incurring compute costs, you can stop/deallocate the VMs and stop the Azure Firewall using Azure CLI.

Prereq:

- Logged into Azure CLI: `az login`

Deallocate the VMs (stops compute billing):

```bash
az vm deallocate -g "acm-connection-monitor-lab" -n "acm-vm-a"
az vm deallocate -g "acm-connection-monitor-lab" -n "acm-vm-b"
```

Stop the Azure Firewall (stops firewall runtime billing):

[Stop Azure Firewall Powershell](https://learn.microsoft.com/en-us/azure/firewall/firewall-faq#how-can-i-stop-and-start-azure-firewall)

Run the commands for the subheading **For a firewall with a Management NIC:**
Run the commands inside the CLI in the Azure Portal if you don't have Powershell locally.

To bring everything back:

```bash
az vm start -g "acm-connection-monitor-lab" -n "acm-vm-a"
az vm start -g "acm-connection-monitor-lab" -n "acm-vm-b"
```

### Stop the FW
```ps
$azfw = Get-AzFirewall -Name "acm-azfw" -ResourceGroupName "acm-connection-monitor-lab"
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw
```

### Start the FW
```ps
$azfw = Get-AzFirewall -Name "acm-azfw" -ResourceGroupName "acm-connection-monitor-lab"
$vnet = Get-AzVirtualNetwork -ResourceGroupName "acm-connection-monitor-lab" -Name "acm-vnet-hub"
$pip = Get-AzPublicIpAddress -ResourceGroupName "acm-connection-monitor-lab" -Name "acm-azfw-pip"
$mgmtPip = Get-AzPublicIpAddress -ResourceGroupName "acm-connection-monitor-lab" -name "acm-azfw-mgmt-pip"
$azfw.Allocate($vnet, $pip, $mgmtPip)
Set-AzFirewall -AzureFirewall $azfw
```

Note: even when stopped, some resources (e.g., public IPs, Log Analytics ingestion) can still incur costs depending on usage.

## Cleanup

Once you're done with the lab and want to remove everything you can do so by either: 

- Delete everything with Terraform: `terraform destroy -auto-approve`
- Delete the resource group in the Azure portal named `acm-connection-monitor-lab`