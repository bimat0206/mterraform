# -----------------------------------------------------------------------------
# Naming convention inputs
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming (e.g., 'tsk')"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'prod', 'staging')"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., 'app', 'platform')"
}

variable "service" {
  type        = string
  default     = null
  description = "Service name override. Defaults to 'vpc' if not provided"
}

variable "identifier" {
  type        = string
  default     = null
  description = "Unique identifier for the resource (e.g., '01', 'a')"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# VPC configuration inputs
# -----------------------------------------------------------------------------
variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC (e.g., '10.0.0.0/16')"
}

variable "secondary_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of secondary CIDR blocks to associate with the VPC"
}

variable "enable_ipv6" {
  type        = bool
  default     = false
  description = "Enable IPv6 CIDR block for the VPC"
}

variable "instance_tenancy" {
  type        = string
  default     = "default"
  description = "Tenancy option for instances launched into the VPC (default or dedicated)"
  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "instance_tenancy must be either 'default' or 'dedicated'"
  }
}

# -----------------------------------------------------------------------------
# DNS configuration
# -----------------------------------------------------------------------------
variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable DNS hostnames in the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS support in the VPC"
}

# -----------------------------------------------------------------------------
# Subnet configuration
# -----------------------------------------------------------------------------
variable "az_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones to use for subnets"
  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6
    error_message = "az_count must be between 1 and 6"
  }
}

variable "public_subnet_suffix" {
  type        = string
  default     = "public"
  description = "Suffix for public subnet names"
}

variable "private_subnet_suffix" {
  type        = string
  default     = "private"
  description = "Suffix for private subnet names"
}

variable "database_subnet_suffix" {
  type        = string
  default     = "database"
  description = "Suffix for database subnet names"
}

variable "create_database_subnets" {
  type        = bool
  default     = false
  description = "Create dedicated database subnets"
}

variable "create_database_subnet_group" {
  type        = bool
  default     = false
  description = "Create database subnet group (requires create_database_subnets = true)"
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Auto-assign public IP on launch for instances in public subnets"
}

# -----------------------------------------------------------------------------
# NAT Gateway configuration
# -----------------------------------------------------------------------------
variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for private subnets"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
}

variable "one_nat_gateway_per_az" {
  type        = bool
  default     = false
  description = "Create one NAT Gateway per AZ for high availability"
}

# -----------------------------------------------------------------------------
# VPN Gateway configuration
# -----------------------------------------------------------------------------
variable "enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "Enable VPN Gateway"
}

variable "vpn_gateway_az" {
  type        = string
  default     = null
  description = "Availability Zone for the VPN Gateway"
}

variable "propagate_vpn_routes_to_private_route_tables" {
  type        = bool
  default     = false
  description = "Propagate VPN routes to private route tables"
}

variable "propagate_vpn_routes_to_public_route_tables" {
  type        = bool
  default     = false
  description = "Propagate VPN routes to public route tables"
}

# -----------------------------------------------------------------------------
# VPC Flow Logs configuration
# -----------------------------------------------------------------------------
variable "enable_flow_logs" {
  type        = bool
  default     = false
  description = "Enable VPC Flow Logs"
}

variable "flow_logs_destination_type" {
  type        = string
  default     = "cloud-watch-logs"
  description = "Type of flow logs destination (cloud-watch-logs or s3)"
  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_logs_destination_type)
    error_message = "flow_logs_destination_type must be either 'cloud-watch-logs' or 's3'"
  }
}

variable "flow_logs_destination_arn" {
  type        = string
  default     = ""
  description = "ARN of CloudWatch Log Group or S3 bucket for flow logs (auto-created if empty)"
}

variable "flow_logs_traffic_type" {
  type        = string
  default     = "ALL"
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type must be ACCEPT, REJECT, or ALL"
  }
}

variable "flow_logs_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log group retention in days (only for cloud-watch-logs destination)"
}


# -----------------------------------------------------------------------------
# DHCP Options configuration
# -----------------------------------------------------------------------------
variable "enable_dhcp_options" {
  type        = bool
  default     = false
  description = "Enable custom DHCP options"
}

variable "dhcp_options_domain_name" {
  type        = string
  default     = ""
  description = "Domain name for DHCP options"
}

variable "dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "List of name servers for DHCP options"
}

variable "dhcp_options_ntp_servers" {
  type        = list(string)
  default     = []
  description = "List of NTP servers for DHCP options"
}

variable "dhcp_options_netbios_name_servers" {
  type        = list(string)
  default     = []
  description = "List of NetBIOS name servers for DHCP options"
}

variable "dhcp_options_netbios_node_type" {
  type        = number
  default     = 2
  description = "NetBIOS node type for DHCP options"
}

# -----------------------------------------------------------------------------
# Network ACL configuration
# -----------------------------------------------------------------------------
variable "manage_default_network_acl" {
  type        = bool
  default     = false
  description = "Manage the default network ACL"
}

variable "default_network_acl_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of ingress rules for default network ACL"
}

variable "default_network_acl_egress" {
  type        = list(map(string))
  default     = []
  description = "List of egress rules for default network ACL"
}

variable "public_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Create dedicated network ACL for public subnets"
}

variable "private_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Create dedicated network ACL for private subnets"
}

# -----------------------------------------------------------------------------
# Default Security Group configuration
# -----------------------------------------------------------------------------
variable "manage_default_security_group" {
  type        = bool
  default     = false
  description = "Manage the default security group"
}

variable "default_security_group_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of ingress rules for default security group"
}

variable "default_security_group_egress" {
  type        = list(map(string))
  default     = []
  description = "List of egress rules for default security group"
}

# -----------------------------------------------------------------------------
# Default Route Table configuration
# -----------------------------------------------------------------------------
variable "manage_default_route_table" {
  type        = bool
  default     = false
  description = "Manage the default route table"
}

variable "default_route_table_routes" {
  type        = list(map(string))
  default     = []
  description = "List of routes for default route table"
}
