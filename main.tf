locals {
  default_create_duration_delay  = "10s"
  default_destroy_duration_delay = "50s"
}

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
  tags                = var.tags

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

  # Block for Point-2-Site VPN
  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_config
    content {
      address_space        = lookup(vpn_client_configuration.value, "address_space", [])
      aad_tenant           = lookup(vpn_client_configuration.value, "aad_tenant", null)
      aad_audience         = lookup(vpn_client_configuration.value, "aad_audience", null)
      aad_issuer           = lookup(vpn_client_configuration.value, "aad_issuer", null)
      vpn_client_protocols = lookup(vpn_client_configuration.value, "vpn_client_protocols", null)
    }
  }
}

# Create local network gateways (on-premise gateway) for Site-to-Site VPNs. 
resource "azurerm_local_network_gateway" "local_gw" {
  for_each            = var.vpn_config.local_gw
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_space
  tags                = var.tags
}
# Add delay after creation and deletion of local gateway resource
resource "time_sleep" "after_local_gateway" {
  depends_on = [
    azurerm_local_network_gateway.local_gw
  ]
  create_duration  = local.default_create_duration_delay
  destroy_duration = local.default_destroy_duration_delay
}


# Create network gateway connections (Site-To-Site VPNs)
resource "azurerm_virtual_network_gateway_connection" "local_gw_connection" {
  for_each            = var.vpn_config.connections
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw[each.value.local_net_gw_name].id
  connection_protocol        = "IKEv2"
  #dpd_timeout_seconds                = lookup(each.value, "dpd_timeout_seconds", "45")
  use_policy_based_traffic_selectors = lookup(each.value, "use_policy_based_traffic_selector", "true")
  shared_key                         = each.value.shared_key
  tags                               = var.tags

  dynamic "ipsec_policy" {
    for_each = each.value.ipsec_policy
    content {
      dh_group         = lookup(ipsec_policy.value, "dh_group", "DHGroup14")
      ike_encryption   = lookup(ipsec_policy.value, "ike_encryption", "AES256")
      ike_integrity    = lookup(ipsec_policy.value, "ike_integrity", "SHA256")
      ipsec_encryption = lookup(ipsec_policy.value, "ipsec_encryption", "AES256")
      ipsec_integrity  = lookup(ipsec_policy.value, "ipsec_integrity", "SHA256")
      pfs_group        = lookup(ipsec_policy.value, "pfs_group", "PFS2048")
      sa_datasize      = lookup(ipsec_policy.value, "sa_datasize", "102400000")
      sa_lifetime      = lookup(ipsec_policy.value, "sa_lifetime", "28800")
    }
  }
}

# Add delay after creation and deletion of network gateway connections
resource "time_sleep" "after_network_connection" {
  depends_on = [
    azurerm_virtual_network_gateway_connection.local_gw_connection
  ]
  create_duration  = local.default_create_duration_delay
  destroy_duration = local.default_destroy_duration_delay
}