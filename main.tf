resource "random_string" "pip_dns" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_public_ip" "gw_pip" {
  name                = "${var.vnet_gw_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = lookup(var.public_ip, "allocation_method", "Dynamic")
  domain_name_label = format("%sgw%s", lower(replace(var.vnet_gw_name, "/[[:^alnum:]]/", "")), random_string.pip_dns.result)
  sku               = lookup(var.public_ip, "sku", "Basic")
  tags              = var.tags
}

resource "azurerm_virtual_network_gateway" "gw" {
  name                = var.vnet_gw_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = var.active_active # Defaults to false. ActiveActive not yet supported with this module.
  enable_bgp    = var.enable_bgp
  sku           = var.sku
  generation    = var.generation # Generation2 requires SKU larger than VpnGw2

  ip_configuration {
    name                          = "${var.vnet_gw_name}-ipconfig"
    public_ip_address_id          = azurerm_public_ip.gw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  tags = var.tags
}


resource "azurerm_local_network_gateway" "local_gw" {
  name                = "lgw-${var.local_networks.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.local_networks.gateway_address
  address_space       = var.local_networks.address_space
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "local_gw_connection" {
  name                = "lgwcon-${var.local_networks.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPSec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw.id

  shared_key = var.local_networks.shared_key

  dynamic "ipsec_policy" {
    for_each = var.local_networks.ipsec_policy != null ? [true] : []
    content {
      dh_group         = lookup(var.local_networks.ipsec_policy, "dh_group", "DHGroup14")
      ike_encryption   = lookup(var.local_networks.ipsec_policy, "ike_encryption", "AES256" )
      ike_integrity    = lookup(var.local_networks.ipsec_policy, "ike_integrity", "SHA384")
      ipsec_encryption = lookup(var.local_networks.ipsec_policy, "ipsec_encryption", "AES256")
      ipsec_integrity  = lookup(var.local_networks.ipsec_policy, "ipsec_integrity", "SHA256")
      pfs_group        = lookup(var.local_networks.ipsec_policy, "pfs_group", "PFS2048")
      sa_datasize      = lookup(var.local_networks.ipsec_policy, "sa_datasize", "102400000")
      sa_lifetime      = lookup(var.local_networks.ipsec_policy, "sa_lifetime", "28800")
    }
  }

  tags = var.tags
}
