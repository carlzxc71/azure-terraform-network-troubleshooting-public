variable "azure_subscription_id" {
  type        = string
  description = "Your Azure subcription ID"
  default     = "put-your-subscription-id-here"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming Azure resources."
  default     = "acm"
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "swedencentral"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
  default     = "acm-connection-monitor-lab"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags applied to resources."
  default     = {}
}

variable "admin_username" {
  type        = string
  description = "Linux admin username for both VMs."
  default     = "azureuser"
}

variable "vm_size" {
  type        = string
  description = "VM size for both Linux VMs."
  default     = "Standard_B2s"
}

variable "vnet_a_cidr" {
  type        = string
  description = "CIDR for VNet A address space."
  default     = "10.10.0.0/22"
}

variable "subnet_a_cidr" {
  type        = string
  description = "CIDR for Subnet A."
  default     = "10.10.1.0/24"
}

variable "vnet_b_cidr" {
  type        = string
  description = "CIDR for VNet B address space."
  default     = "10.20.0.0/22"
}

variable "subnet_b_cidr" {
  type        = string
  description = "CIDR for Subnet B."
  default     = "10.20.1.0/24"
}

variable "vnet_hub_cidr" {
  type        = string
  description = "CIDR for the hub VNet (hosts Azure Firewall)."
  default     = "10.30.0.0/24"
}

variable "azure_firewall_subnet_cidr" {
  type        = string
  description = "CIDR for AzureFirewallSubnet (must be /26 or larger)."
  default     = "10.30.0.0/26"
}

variable "azure_firewall_management_subnet_cidr" {
  type        = string
  description = "CIDR for AzureFirewallManagementSubnet (required for Azure Firewall Basic management IP configuration; use /26 or larger)."
  default     = "10.30.0.64/26"
}

variable "email_alert_receiver" {
  type        = string
  description = "The receiver of the Azure Alert email"
  default     = "enteryour@email.com"
}
