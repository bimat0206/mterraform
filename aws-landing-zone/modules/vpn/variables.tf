variable "name" {
  description = "Name suffix for the VPN Connection (e.g., 'vpn-dc-01')."
  type        = string
}

variable "customer_gateway_name" {
  description = "Name for the Customer Gateway (e.g., 'dc-gateway-01')."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Global prefix for all resources (e.g., 'pb-network')."
  type        = string
  default     = ""
}

variable "customer_gateway_ip" {
  description = "The public IP address of the customer gateway device."
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "The BGP ASN of the customer gateway device."
  type        = number
}

variable "transit_gateway_id" {
  description = "The ID of the Transit Gateway to attach the VPN connection to."
  type        = string
}

variable "static_routes_only" {
  description = "Whether the VPN connection uses static routes exclusively (no BGP)."
  type        = bool
  default     = false # Default to using BGP as per TGW best practices
}

# Optional: Specify inside tunnel CIDRs if needed (rarely required with TGW)
variable "inside_ip_cidr_tunnel1" {
  description = "The CIDR block for the inside IP addresses of tunnel 1 (e.g., 169.254.10.0/30)."
  type        = string
  default     = null
}

variable "inside_ip_cidr_tunnel2" {
  description = "The CIDR block for the inside IP addresses of tunnel 2 (e.g., 169.254.11.0/30)."
  type        = string
  default     = null
}

# Optional: Specify pre-shared keys if you don't want AWS to generate them
variable "preshared_key_tunnel1" {
  description = "Pre-shared key for tunnel 1. Must be alphanumeric and 8-64 chars."
  type        = string
  default     = null
  sensitive   = true
}

variable "preshared_key_tunnel2" {
  description = "Pre-shared key for tunnel 2. Must be alphanumeric and 8-64 chars."
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
