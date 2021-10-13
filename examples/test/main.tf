terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "gw_test" {
  name     = "rg-gateway-test"
  location = "uksouth"
}

resource "azurerm_virtual_network" "gw_test_vn" {
  name                = "virtualNetwork1"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.gw_test.name
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "sn_gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.gw_test.name
  virtual_network_name = azurerm_virtual_network.gw_test_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}


module "vpn_dev" {
  source = "../../"

  location            = "uksouth"
  resource_group_name = azurerm_resource_group.gw_test.name
  vnet_gw_name        = "gw_test"
  sku                 = "VpnGw2"
  generation          = "Generation2"
  subnet_id           = azurerm_subnet.sn_gw.id

  public_ip = {
    sku               = "Basic"
    allocation_method = "Dynamic"
  }

  vpn_config = {
    local_gw = {
      "main_dc" = {
        gateway_address = "8.1.2.3"
        address_space   = ["10.200.0.0/24"]
      },
      "second_dc" = {
        gateway_address = "8.1.2.4"
        address_space   = ["10.201.0.0/24"]
      },
      "dummy_dc" = {
        gateway_address = "8.1.2.5"
        address_space   = ["10.202.0.0/24"]
      }
    }
    connections = {
      "main_vpn" = {
        shared_key        = "iuhwieuhi"
        local_net_gw_name = "main_dc"
        ipsec_policy = {
          dh_group = "DHGroup24"
        }
      },
      "second_vpn" = {
        shared_key        = "iu3423ei"
        local_net_gw_name = "second_dc"
        ipsec_policy = {
          dh_group = "DHGroup14"
        }
      },
      "dummy_vpn" = {
        shared_key        = "iuey87ty32789qdiuewbh"
        local_net_gw_name = "dummy_dc"
        ipsec_policy = {
          dh_group = "DHGroup14"
        }
      },
    }
  }
}