variable "name" {
  type        = string
  description = "VPN name"
}

variable "nat_ips" {
  type        = list(string)
  default     = []
  description = "List of self_links of external IPs. Changing this forces a new NAT to be created."
}
