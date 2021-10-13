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
  for_each = var.vpn_config.local_gw
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_space
  tags                = var.tags
}


resource "azurerm_virtual_network_gateway_connection" "local_gw_connection" {
  for_each            = var.vpn_config.connections
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPSec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw[each.value.local_net_gw_name].id
  connection_protocol        = "IKEv2"

  shared_key = each.value.shared_key

  dynamic "ipsec_policy" {
    for_each = each.value.ipsec_policy != null ? [true] : []
    content {
      dh_group         = lookup(each.value, "dh_group", "DHGroup14")
      ike_encryption   = lookup(each.value, "ike_encryption", "AES256" )
      ike_integrity    = lookup(each.value, "ike_integrity", "SHA256")
      ipsec_encryption = lookup(each.value, "ipsec_encryption", "AES256")
      ipsec_integrity  = lookup(each.value, "ipsec_integrity", "SHA256")
      pfs_group        = lookup(each.value, "pfs_group", "PFS2048")
      sa_datasize      = lookup(each.value, "sa_datasize", "102400000")
      sa_lifetime      = lookup(each.value, "sa_lifetime", "28800")
    }
  }

  tags = var.tags
}

