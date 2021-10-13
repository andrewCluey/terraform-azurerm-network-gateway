

variable "location" {
  type        = string
  description = "description"
  default = "uksouth"
}

variable "resource_group_name" {
  type        = string
  description = "description"
}

variable "vnet_gw_name" {
  type        = string
  description = "description"
}

variable "generation" {
  type        = string
  description = "description"
  default     = "Basic"
}


variable "active_active" {
  type        = bool
  description = "description"
  default     = false
}

variable "enable_bgp" {
  type        = bool
  description = "description"
  default     = false
}

variable "public_ip" {
  type = object({
    sku = string
    allocation_method = string
  })
}

variable "sku" {
  type        = string
  description = "description"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "description"
}

variable "tags" {
  type        = map
  description = "description"
  default     = {}
}

variable "vpn_config" {
  type        = any
  description = <<EOF
  Input object to define an Azure Site-Site VPN connection. Multiple Local Netowrk gateways & VPN connections can be defined.
EXAMPLE:

vpn_config = {
  local_gw = {
    "main_dc" = {
      gateway_address = "8.1.2.3"
      address_space   = ["10.200.0.0/24"]
    },
    "second_dc" = {
      gateway_address = "8.1.2.4"
      address_space   = ["10.201.0.0/24"]
    }
  connections = {
    "main_vpn" = {
      shared_key        = "iuhwieuhi"
      local_net_gw_name = "main_dc"
      ipsec_policy      = {
        dh_group = "DHGroup24"
      }
    },
    "second_vpn" = {
      shared_key        = "iu3423ei"
      local_net_gw_name = "second_dc"
      ipsec_policy      = {
        dh_group = "DHGroup14"
      }
    }
}
EOF
}

