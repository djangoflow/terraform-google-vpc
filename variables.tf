variable "name" {
  type        = string
  description = "VPN name"
}

variable "description" {
  type        = string
  description = "VPN description"
  default     = null
}

variable "enable_ula_internal_ipv6" {
  type        = bool
  description = "Enable ULA internal ipv6"
  default     = null
}

variable "nat_ips" {
  type        = list(string)
  default     = []
  description = "List of self_links of external IPs. Changing this forces a new NAT to be created."
}
