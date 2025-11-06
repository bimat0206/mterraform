# -----------------------------------------------------------------------------
# General configuration
# -----------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS region where resources will be created"
}

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

# -----------------------------------------------------------------------------
# Tagging
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# VPC Basic Configuration
# -----------------------------------------------------------------------------
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "vpc_secondary_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of secondary CIDR blocks to associate with the VPC"
}

variable "vpc_enable_ipv6" {
  type        = bool
  default     = false
  description = "Enable IPv6 CIDR block for the VPC"
}

variable "vpc_instance_tenancy" {
  type        = string
  default     = "default"
  description = "Tenancy option for instances launched into the VPC"
}

# -----------------------------------------------------------------------------
# DNS Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable DNS hostnames in the VPC"
}

variable "vpc_enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS support in the VPC"
}

# -----------------------------------------------------------------------------
# Subnet Configuration
# -----------------------------------------------------------------------------
variable "vpc_az_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones for VPC subnets"
}

variable "vpc_public_subnet_suffix" {
  type        = string
  default     = "public"
  description = "Suffix for public subnet names"
}

variable "vpc_private_subnet_suffix" {
  type        = string
  default     = "private"
  description = "Suffix for private subnet names"
}

variable "vpc_database_subnet_suffix" {
  type        = string
  default     = "database"
  description = "Suffix for database subnet names"
}

variable "vpc_create_database_subnets" {
  type        = bool
  default     = false
  description = "Create dedicated database subnets"
}

variable "vpc_create_database_subnet_group" {
  type        = bool
  default     = false
  description = "Create database subnet group"
}

variable "vpc_map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Auto-assign public IP on launch for instances in public subnets"
}

# -----------------------------------------------------------------------------
# NAT Gateway Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for VPC private subnets"
}

variable "vpc_single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use a single NAT Gateway for all private subnets"
}

variable "vpc_one_nat_gateway_per_az" {
  type        = bool
  default     = false
  description = "Create one NAT Gateway per AZ for high availability"
}

# -----------------------------------------------------------------------------
# VPN Gateway Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "Enable VPN Gateway"
}

variable "vpc_vpn_gateway_az" {
  type        = string
  default     = null
  description = "Availability Zone for the VPN Gateway"
}

variable "vpc_propagate_vpn_routes_to_private_route_tables" {
  type        = bool
  default     = false
  description = "Propagate VPN routes to private route tables"
}

variable "vpc_propagate_vpn_routes_to_public_route_tables" {
  type        = bool
  default     = false
  description = "Propagate VPN routes to public route tables"
}

# -----------------------------------------------------------------------------
# VPC Flow Logs Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_flow_logs" {
  type        = bool
  default     = false
  description = "Enable VPC Flow Logs"
}

variable "vpc_flow_logs_destination_type" {
  type        = string
  default     = "cloud-watch-logs"
  description = "Type of flow logs destination"
}

variable "vpc_flow_logs_destination_arn" {
  type        = string
  default     = ""
  description = "ARN of CloudWatch Log Group or S3 bucket for flow logs"
}

variable "vpc_flow_logs_traffic_type" {
  type        = string
  default     = "ALL"
  description = "Type of traffic to log"
}

variable "vpc_flow_logs_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log group retention in days"
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# VPC Gateway Endpoints Configuration
# -----------------------------------------------------------------------------
variable "vpce_gateway_enabled" {
  type        = bool
  default     = false
  description = "Enable VPC Gateway Endpoints module"
}

variable "vpce_enable_s3_endpoint" {
  type        = bool
  default     = true
  description = "Enable S3 VPC Gateway Endpoint (FREE)"
}

variable "vpce_enable_dynamodb_endpoint" {
  type        = bool
  default     = false
  description = "Enable DynamoDB VPC Gateway Endpoint (FREE)"
}

# -----------------------------------------------------------------------------
# VPC Interface Endpoints Configuration
# -----------------------------------------------------------------------------
variable "vpce_interface_enabled" {
  type        = bool
  default     = false
  description = "Enable VPC Interface Endpoints module"
}

variable "vpce_interface_endpoints" {
  type        = map(bool)
  default     = {}
  description = "Map of AWS services to create interface endpoints for (e.g., { ec2 = true, ssm = true })"
}

variable "vpce_private_dns_enabled" {
  type        = bool
  default     = true
  description = "Enable private DNS for interface endpoints"
}

# -----------------------------------------------------------------------------
# DHCP Options Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_dhcp_options" {
  type        = bool
  default     = false
  description = "Enable custom DHCP options"
}

variable "vpc_dhcp_options_domain_name" {
  type        = string
  default     = ""
  description = "Domain name for DHCP options"
}

variable "vpc_dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "List of name servers for DHCP options"
}

variable "vpc_dhcp_options_ntp_servers" {
  type        = list(string)
  default     = []
  description = "List of NTP servers for DHCP options"
}

variable "vpc_dhcp_options_netbios_name_servers" {
  type        = list(string)
  default     = []
  description = "List of NetBIOS name servers for DHCP options"
}

variable "vpc_dhcp_options_netbios_node_type" {
  type        = number
  default     = 2
  description = "NetBIOS node type for DHCP options"
}

# -----------------------------------------------------------------------------
# Network ACL Configuration
# -----------------------------------------------------------------------------
variable "vpc_manage_default_network_acl" {
  type        = bool
  default     = false
  description = "Manage the default network ACL"
}

variable "vpc_default_network_acl_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of ingress rules for default network ACL"
}

variable "vpc_default_network_acl_egress" {
  type        = list(map(string))
  default     = []
  description = "List of egress rules for default network ACL"
}

variable "vpc_public_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Create dedicated network ACL for public subnets"
}

variable "vpc_private_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Create dedicated network ACL for private subnets"
}

# -----------------------------------------------------------------------------
# Default Security Group Configuration
# -----------------------------------------------------------------------------
variable "vpc_manage_default_security_group" {
  type        = bool
  default     = false
  description = "Manage the default security group"
}

variable "vpc_default_security_group_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of ingress rules for default security group"
}

variable "vpc_default_security_group_egress" {
  type        = list(map(string))
  default     = []
  description = "List of egress rules for default security group"
}

# -----------------------------------------------------------------------------
# Default Route Table Configuration
# -----------------------------------------------------------------------------
variable "vpc_manage_default_route_table" {
  type        = bool
  default     = false
  description = "Manage the default route table"
}

variable "vpc_default_route_table_routes" {
  type        = list(map(string))
  default     = []
  description = "List of routes for default route table"
}

# -----------------------------------------------------------------------------
# ACM Configuration
# -----------------------------------------------------------------------------
variable "acm_domain_name" {
  type        = string
  description = "Primary domain name for ACM certificate"
  default     = ""
}

variable "acm_subject_alternative_names" {
  type        = list(string)
  description = "Subject Alternative Names (SANs) for ACM certificate"
  default     = []
}

variable "acm_hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for ACM DNS validation"
  default     = ""
}

variable "acm_enabled" {
  type        = bool
  description = "Whether to create ACM certificate"
  default     = false
}
