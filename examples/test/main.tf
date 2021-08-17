terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.60.0"
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

  public_ip           = {
    sku = "Basic"
    allocation_method = "Dynamic"
  }
  
  local_networks = {
      name            = "dev-op-ln"
      gateway_address = "8.8.8.8"
      address_space   = ["192.168.1.0/24"]
      shared_key      = "test-shared-key"
      ipsec_policy = {
        dh_group = "DHGroup14"
      }
    }
}