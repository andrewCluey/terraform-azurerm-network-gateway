

variable "location" {
  type        = string
  description = "description"
  default     = "uksouth"
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
    sku               = string
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
  type        = map(any)
  description = "description"
  default     = {}
}

variable "vpn_config" {
  type        = any
  description = <<EOF
  Input object to define Local network gateways and VPN connections. Multiple Local Network gateways & VPN connections can be defined.
  Input Parameters:
  - local_gw    : An input map object to define local network gateways for Site-to-Site VPNs. More than one is allowed.
  - connections : An Input map object to define a Site-to-Site VPN Connection. More than one is allowed.

  The local_gw parameter is an input map, so requires a `key` (which is the name that will be assigned to the new Local Gateway) 
  and 2 `values`. The values required are:

  - gateway_address : The Public IP Address of the remote endpoint for the 'on-premise' VPN Device. 
  - address_space   : A list of network addresses (in CIDR notation), that is 'behind' the on-premise VPN device.

  The `connections` parameter is an input map object, and also requires a `key` (which is to be the assigned name for the connection) and
  several values. Not all of these are required as default values will be configured if they are not used:
  
  - use_policy_based_traffic_selector : Boolean. 
  - shared_key                        : String. The shared key to be used for the VPN connection. Avoid setting this in plain text.
  - ipsec_policy                      : Map object (Requires a `key` and `Values`). Optional. See example below for default values. 
  
The example code block below shows the structure for defining an ipsec policy. The settings used are also the default values if the `ipsec_policy` parameter is ommitted.  

```
connections = {
  vpn_connection1 = {
    name              = "VPNC-prod-uks-to-Blender-prod-01"
    local_net_gw_name = "lngw-Blender-Prod-uks-01"
    ipsec_policy      = {
      vpn1 = {
        dh_group         = "DHGroup14"
        ike_encryption   = "AES256"
        ike_integrity    = "SHA256"
        ipsec_encryption = "AES256"
        ipsec_integrity  = "SHA256"
        pfs_group        = "PFS2048"
        sa_datasize      = "102400000"
        sa_lifetime      = "28800"
      }
    }
  }
}
   
```

EXAMPLE:
```
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
```
EOF
}

