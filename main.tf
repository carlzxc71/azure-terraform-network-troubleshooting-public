terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "azapi" {}

provider "random" {}

data "azapi_client_config" "current" {}

resource "random_password" "admin" {
  length  = 24
  special = true
}

resource "azapi_resource" "rg" {
  type      = local.api.resource_groups
  name      = var.resource_group_name
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  location  = var.location
  tags      = var.tags

  body = {
    properties = {}
  }
}

resource "azapi_resource" "vnet_a" {
  type      = local.api.virtual_networks
  name      = local.names.vnet_a
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      addressSpace = {
        addressPrefixes = [var.vnet_a_cidr]
      }
    }
  }
}

resource "azapi_resource" "vnet_b" {
  type      = local.api.virtual_networks
  name      = local.names.vnet_b
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      addressSpace = {
        addressPrefixes = [var.vnet_b_cidr]
      }
    }
  }
}

resource "azapi_resource" "nsg_a" {
  type      = local.api.network_security_groups
  name      = local.names.nsg_a
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      securityRules = [
        {
          name = "DenyAllInbound"
          properties = {
            priority                 = 4096
            direction                = "Inbound"
            access                   = "Deny"
            protocol                 = "*"
            sourcePortRange          = "*"
            destinationPortRange     = "*"
            sourceAddressPrefix      = "*"
            destinationAddressPrefix = "*"
            description              = "Deny all inbound traffic"
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "nsg_b" {
  type      = local.api.network_security_groups
  name      = local.names.nsg_b
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      securityRules = [
        {
          name = "AllowInboundTcp443FromPartner"
          properties = {
            priority                 = 110
            direction                = "Inbound"
            access                   = "Allow"
            protocol                 = "Tcp"
            sourcePortRange          = "*"
            destinationPortRange     = "443"
            sourceAddressPrefix      = "172.20.5.0/24"
            destinationAddressPrefix = "*"
            description              = "Makeup rule: allow HTTPS from partner subnet"
          }
        },
        {
          name = "DenyInboundUdp53FromInternet"
          properties = {
            priority                 = 120
            direction                = "Inbound"
            access                   = "Deny"
            protocol                 = "Udp"
            sourcePortRange          = "*"
            destinationPortRange     = "53"
            sourceAddressPrefix      = "0.0.0.0/0"
            destinationAddressPrefix = "*"
            description              = "Makeup rule: deny inbound DNS"
          }
        },
        {
          name = "AllowInboundUdp123FromNtpServers"
          properties = {
            priority                 = 130
            direction                = "Inbound"
            access                   = "Allow"
            protocol                 = "Udp"
            sourcePortRange          = "*"
            destinationPortRange     = "123"
            sourceAddressPrefix      = "198.51.100.0/24"
            destinationAddressPrefix = "*"
            description              = "Makeup rule: allow NTP from example range"
          }
        },
        {
          name = "AllowInboundTcp3389FromJumpbox"
          properties = {
            priority                 = 140
            direction                = "Inbound"
            access                   = "Allow"
            protocol                 = "Tcp"
            sourcePortRange          = "*"
            destinationPortRange     = "3389"
            sourceAddressPrefix      = "192.168.50.10"
            destinationAddressPrefix = "*"
            description              = "Makeup rule: allow RDP from jumpbox"
          }
        },
        {
          name = "DenyInboundIcmpFromTestNet"
          properties = {
            priority                 = 150
            direction                = "Inbound"
            access                   = "Deny"
            protocol                 = "Icmp"
            sourcePortRange          = "*"
            destinationPortRange     = "*"
            sourceAddressPrefix      = "203.0.113.0/24"
            destinationAddressPrefix = "*"
            description              = "Makeup rule: deny ICMP from example range"
          }
        },
        {
          name = "AllowInboundTcp8080FromDevSubnet"
          properties = {
            priority                 = 160
            direction                = "Inbound"
            access                   = "Allow"
            protocol                 = "Tcp"
            sourcePortRange          = "*"
            destinationPortRange     = "8080"
            sourceAddressPrefix      = "10.42.0.0/16"
            destinationAddressPrefix = "*"
            description              = "Makeup rule: allow app port from dev"
          }
        },
        {
          name = "AllowOutboundTcp1433ToSql"
          properties = {
            priority                 = 170
            direction                = "Outbound"
            access                   = "Allow"
            protocol                 = "Tcp"
            sourcePortRange          = "*"
            destinationPortRange     = "1433"
            sourceAddressPrefix      = "*"
            destinationAddressPrefix = "10.60.0.4"
            description              = "Makeup rule: allow outbound SQL"
          }
        },
        {
          name = "DenyOutboundUdp161ToMgmtNet"
          properties = {
            priority                 = 180
            direction                = "Outbound"
            access                   = "Deny"
            protocol                 = "Udp"
            sourcePortRange          = "*"
            destinationPortRange     = "161"
            sourceAddressPrefix      = "*"
            destinationAddressPrefix = "172.31.0.0/16"
            description              = "Makeup rule: deny outbound SNMP"
          }
        },
        {
          name = "AllowOutboundAnyToExample"
          properties = {
            priority                 = 190
            direction                = "Outbound"
            access                   = "Allow"
            protocol                 = "*"
            sourcePortRange          = "*"
            destinationPortRange     = "*"
            sourceAddressPrefix      = "*"
            destinationAddressPrefix = "192.0.2.0/24"
            description              = "Makeup rule: allow outbound to example range"
          }
        },
        {
          name = "DenyAllInbound"
          properties = {
            priority                 = 4096
            direction                = "Inbound"
            access                   = "Deny"
            protocol                 = "*"
            sourcePortRange          = "*"
            destinationPortRange     = "*"
            sourceAddressPrefix      = "*"
            destinationAddressPrefix = "*"
            description              = "Deny all inbound traffic"
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "subnet_a" {
  type      = local.api.subnets
  name      = local.names.subnet_a
  parent_id = azapi_resource.vnet_a.id

  body = {
    properties = {
      addressPrefix = var.subnet_a_cidr
      networkSecurityGroup = {
        id = azapi_resource.nsg_a.id
      }
      routeTable = {
        id = azapi_resource.rt_a.id
      }
    }
  }
}

resource "azapi_resource" "subnet_b" {
  type      = local.api.subnets
  name      = local.names.subnet_b
  parent_id = azapi_resource.vnet_b.id

  body = {
    properties = {
      addressPrefix = var.subnet_b_cidr
      networkSecurityGroup = {
        id = azapi_resource.nsg_b.id
      }
      routeTable = {
        id = azapi_resource.rt_b.id
      }
    }
  }
}

resource "azapi_resource" "rt_a" {
  type      = local.api.route_tables
  name      = local.names.rt_a
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      routes = [
        {
          name = "default"
          properties = {
            addressPrefix    = "0.0.0.0/0"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        },
        {
          name = "rfc1918-10"
          properties = {
            addressPrefix    = "10.0.0.0/8"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        },
        {
          name = "rfc1918-172"
          properties = {
            addressPrefix    = "172.16.0.0/12"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        },
        {
          name = "rfc1918-192"
          properties = {
            addressPrefix    = "192.168.0.0/16"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "rt_b" {
  type      = local.api.route_tables
  name      = local.names.rt_b
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      routes = [
        {
          name = "default"
          properties = {
            addressPrefix    = "0.0.0.0/0"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        },
        {
          name = "rfc1918-10"
          properties = {
            addressPrefix    = "10.0.0.0/8"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        },
        {
          name = "rfc1918-172"
          properties = {
            addressPrefix    = "172.16.0.0/12"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        },
        {
          name = "rfc1918-192"
          properties = {
            addressPrefix    = "192.168.0.0/16"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = azapi_resource.azure_firewall.output.private_ip_address
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "nic_a" {
  type      = local.api.network_interfaces
  name      = local.names.nic_a
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      ipConfigurations = [
        {
          name = "ipconfig1"
          properties = {
            privateIPAllocationMethod = "Dynamic"
            subnet = {
              id = azapi_resource.subnet_a.id
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

resource "azapi_resource" "nic_b" {
  type      = local.api.network_interfaces
  name      = local.names.nic_b
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      ipConfigurations = [
        {
          name = "ipconfig1"
          properties = {
            privateIPAllocationMethod = "Dynamic"
            subnet = {
              id = azapi_resource.subnet_b.id
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

resource "azapi_resource" "vm_a" {
  type      = local.api.virtual_machines
  name      = local.names.vm_a
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      hardwareProfile = {
        vmSize = var.vm_size
      }
      storageProfile = {
        imageReference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }
        osDisk = {
          createOption = "FromImage"
          managedDisk = {
            storageAccountType = "Standard_LRS"
          }
        }
      }
      osProfile = {
        computerName  = local.names.vm_a
        adminUsername = var.admin_username
        adminPassword = random_password.admin.result
        linuxConfiguration = {
          disablePasswordAuthentication = false
        }
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.nic_a.id
            properties = {
              primary = true
            }
          }
        ]
      }
    }
  }
}

resource "azapi_resource" "vm_b" {
  type      = local.api.virtual_machines
  name      = local.names.vm_b
  parent_id = azapi_resource.rg.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      hardwareProfile = {
        vmSize = var.vm_size
      }
      storageProfile = {
        imageReference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }
        osDisk = {
          createOption = "FromImage"
          managedDisk = {
            storageAccountType = "Standard_LRS"
          }
        }
      }
      osProfile = {
        computerName  = local.names.vm_b
        adminUsername = var.admin_username
        adminPassword = random_password.admin.result
        linuxConfiguration = {
          disablePasswordAuthentication = false
        }
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.nic_b.id
            properties = {
              primary = true
            }
          }
        ]
      }
    }
  }
}

resource "azapi_resource" "peering_a_to_hub" {
  type      = local.api.vnet_peerings
  name      = "peer-a-to-hub"
  parent_id = azapi_resource.vnet_a.id

  body = {
    properties = {
      remoteVirtualNetwork = {
        id = azapi_resource.vnet_hub.id
      }
      allowVirtualNetworkAccess = true
      allowForwardedTraffic     = true
      allowGatewayTransit       = false
      useRemoteGateways         = false
    }
  }
  retry = {
    error_message_regex = ["ReferencedResourceNotProvisioned"]
  }
}

resource "azapi_resource" "peering_hub_to_a" {
  type      = local.api.vnet_peerings
  name      = "peer-hub-to-a"
  parent_id = azapi_resource.vnet_hub.id

  body = {
    properties = {
      remoteVirtualNetwork = {
        id = azapi_resource.vnet_a.id
      }
      allowVirtualNetworkAccess = true
      allowForwardedTraffic     = true
      allowGatewayTransit       = false
      useRemoteGateways         = false
    }
  }
  retry = {
    error_message_regex = ["ReferencedResourceNotProvisioned"]
  }
}

resource "azapi_resource" "peering_b_to_hub" {
  type      = local.api.vnet_peerings
  name      = "peer-b-to-hub"
  parent_id = azapi_resource.vnet_b.id

  body = {
    properties = {
      remoteVirtualNetwork = {
        id = azapi_resource.vnet_hub.id
      }
      allowVirtualNetworkAccess = true
      allowForwardedTraffic     = true
      allowGatewayTransit       = false
      useRemoteGateways         = false
    }
  }
  retry = {
    error_message_regex = ["ReferencedResourceNotProvisioned"]
  }
}

resource "azapi_resource" "peering_hub_to_b" {
  type      = local.api.vnet_peerings
  name      = "peer-hub-to-b"
  parent_id = azapi_resource.vnet_hub.id

  body = {
    properties = {
      remoteVirtualNetwork = {
        id = azapi_resource.vnet_b.id
      }
      allowVirtualNetworkAccess = true
      allowForwardedTraffic     = true
      allowGatewayTransit       = false
      useRemoteGateways         = false
    }
  }
  retry = {
    error_message_regex = ["ReferencedResourceNotProvisioned"]
  }
}
