variable "name" {
  description = "Name suffix for the VPC (e.g., 'ingress', 'egress', 'shareservices')"
  type        = string
}

variable "name_prefix" {
  description = "Global prefix for all resources (e.g., 'pb-network')"
  type        = string
  default     = ""
}

variable "cidr_block" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones to use for subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets. Must match the number of AZs if provided."
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for general-purpose private subnets. Must match the number of AZs if provided."
  type        = list(string)
  default     = []
}

variable "tgw_subnet_cidrs" {
  description = "List of CIDR blocks for dedicated Transit Gateway attachment subnets. Must match the number of AZs if provided."
  type        = list(string)
  default     = []
}

variable "alb_subnet_cidrs" {
  description = "List of CIDR blocks for dedicated ALB subnets. Must match the number of AZs if provided."
  type        = list(string)
  default     = []
}

variable "subnet_names" {
  description = "Map of subnet type to list of custom name suffixes (e.g., {public = ['public-a', 'public-b']})"
  type        = map(list(string))
  default     = {}
}

variable "enable_nat_gateway" {
  description = "Set to true to create NAT Gateways for private subnets (one per AZ or single)."
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Set to true to create a VPN Gateway for the VPC."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Set to true to create a single NAT Gateway in the first public subnet, instead of one per AZ."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "princebank"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "landing-zone"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "landing-zone"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "route_outbound_tgw_subnets_to_nat" {
  description = "Specific flag for Outbound VPC pattern: If true and NAT GW is enabled, add 0.0.0.0/0 route via NAT GW to the TGW subnet route table."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Set to true to enable VPC Flow Logs for the VPC."
  type        = bool
  default     = false
}

variable "flow_log_retention_in_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch Logs."
  type        = number
  default     = 14
}

variable "flow_log_traffic_type" {
  description = "Type of traffic to capture in VPC Flow Logs. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}
