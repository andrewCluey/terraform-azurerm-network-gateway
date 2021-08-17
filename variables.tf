

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

variable "tags" {
  type        = map
  description = "description"
  default     = {}
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


variable "local_networks" {
  description = <<EOF
  List of local virtual network connections to connect to gateway.
    connection_name = string
    name = string,
    gateway_address = string, 
    address_space = list(string), 
    shared_key = string, 
    ipsec_policy = any 
EOF
}

variable "generation" {
  type        = string
  description = "description"
  default     = "Basic"
}
