# -----------------------------------------------------------------------------
# Naming Convention Variables
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod, staging)"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., network, platform)"
}

variable "service" {
  type        = string
  default     = ""
  description = "Service name (e.g., hub, transit). If empty, will use 'tgw'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# Transit Gateway Configuration
# -----------------------------------------------------------------------------
variable "description" {
  type        = string
  default     = ""
  description = "Description of the Transit Gateway"
}

variable "amazon_side_asn" {
  type        = number
  default     = 64512
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session (64512-65534, 4200000000-4294967294)"

  validation {
    condition     = (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) || (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    error_message = "ASN must be in range 64512-65534 or 4200000000-4294967294"
  }
}

variable "auto_accept_shared_attachments" {
  type        = string
  default     = "disable"
  description = "Whether resource attachment requests are automatically accepted (enable or disable)"

  validation {
    condition     = contains(["enable", "disable"], var.auto_accept_shared_attachments)
    error_message = "Must be 'enable' or 'disable'"
  }
}

variable "default_route_table_association" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments are automatically associated with the default association route table (enable or disable)"

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_association)
    error_message = "Must be 'enable' or 'disable'"
  }
}

variable "default_route_table_propagation" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table (enable or disable)"

  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_propagation)
    error_message = "Must be 'enable' or 'disable'"
  }
}

variable "dns_support" {
  type        = string
  default     = "enable"
  description = "Whether DNS support is enabled (enable or disable)"

  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "Must be 'enable' or 'disable'"
  }
}

variable "vpn_ecmp_support" {
  type        = string
  default     = "enable"
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled (enable or disable)"

  validation {
    condition     = contains(["enable", "disable"], var.vpn_ecmp_support)
    error_message = "Must be 'enable' or 'disable'"
  }
}

variable "multicast_support" {
  type        = string
  default     = "disable"
  description = "Whether Multicast support is enabled (enable or disable)"

  validation {
    condition     = contains(["enable", "disable"], var.multicast_support)
    error_message = "Must be 'enable' or 'disable'"
  }
}

variable "transit_gateway_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "One or more IPv4 or IPv6 CIDR blocks for the transit gateway"
}

# -----------------------------------------------------------------------------
# VPC Attachments Configuration
# -----------------------------------------------------------------------------
variable "vpc_attachments" {
  type = map(object({
    vpc_id                                          = string
    subnet_ids                                      = list(string)
    dns_support                                     = optional(string, "enable")
    ipv6_support                                    = optional(string, "disable")
    appliance_mode_support                          = optional(string, "disable")
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
  }))
  default     = {}
  description = "Map of VPC attachments to create"
}

# -----------------------------------------------------------------------------
# Custom Route Tables Configuration
# -----------------------------------------------------------------------------
variable "create_custom_route_tables" {
  type        = bool
  default     = false
  description = "Create custom Transit Gateway route tables"
}

variable "custom_route_tables" {
  type = map(object({
    name = string
  }))
  default     = {}
  description = "Map of custom route tables to create"
}

# -----------------------------------------------------------------------------
# Flow Logs Configuration
# -----------------------------------------------------------------------------
variable "enable_flow_logs" {
  type        = bool
  default     = true
  description = "Enable Transit Gateway Flow Logs"
}

variable "flow_logs_destination_type" {
  type        = string
  default     = "cloud-watch-logs"
  description = "Type of flow logs destination (cloud-watch-logs or s3)"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_logs_destination_type)
    error_message = "Must be 'cloud-watch-logs' or 's3'"
  }
}

variable "flow_logs_s3_bucket_arn" {
  type        = string
  default     = ""
  description = "ARN of S3 bucket for flow logs (required if destination_type is s3)"
}

variable "flow_logs_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain flow logs in CloudWatch (0 = indefinite)"

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_logs_retention_days)
    error_message = "Retention days must be a valid CloudWatch Logs retention value"
  }
}

variable "flow_logs_format" {
  type        = string
  default     = "$${version} $${resource-type} $${account-id} $${tgw-id} $${tgw-attachment-id} $${tgw-src-vpc-account-id} $${tgw-dst-vpc-account-id} $${tgw-src-vpc-id} $${tgw-dst-vpc-id} $${tgw-src-subnet-id} $${tgw-dst-subnet-id} $${tgw-src-eni} $${tgw-dst-eni} $${tgw-src-az-id} $${tgw-dst-az-id} $${tgw-pair-attachment-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${log-status} $${type} $${packets-lost-no-route} $${packets-lost-blackhole} $${packets-lost-mtu-exceeded} $${packets-lost-ttl-expired}"
  description = "Flow logs format (default includes all available fields)"
}

variable "flow_logs_max_aggregation_interval" {
  type        = number
  default     = 60
  description = "Maximum interval of time during which a flow is captured and aggregated (60 or 600 seconds)"

  validation {
    condition     = contains([60, 600], var.flow_logs_max_aggregation_interval)
    error_message = "Must be 60 or 600 seconds"
  }
}

variable "create_flow_logs_iam_role" {
  type        = bool
  default     = true
  description = "Create IAM role for CloudWatch Logs"
}

variable "flow_logs_iam_role_arn" {
  type        = string
  default     = ""
  description = "ARN of existing IAM role for flow logs (used if create_flow_logs_iam_role is false)"
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms Configuration
# -----------------------------------------------------------------------------
variable "enable_cloudwatch_alarms" {
  type        = bool
  default     = true
  description = "Enable CloudWatch alarms for Transit Gateway"
}

variable "alarm_sns_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN for CloudWatch alarms (leave empty to skip alarm actions)"
}

variable "bytes_in_threshold" {
  type        = number
  default     = 1000000000
  description = "Threshold for BytesIn alarm (bytes)"
}

variable "bytes_out_threshold" {
  type        = number
  default     = 1000000000
  description = "Threshold for BytesOut alarm (bytes)"
}

variable "packet_drop_count_blackhole_threshold" {
  type        = number
  default     = 1000
  description = "Threshold for packet drops due to blackhole routes"
}

variable "packet_drop_count_no_route_threshold" {
  type        = number
  default     = 1000
  description = "Threshold for packet drops due to no route"
}

# -----------------------------------------------------------------------------
# Resource Sharing Configuration
# -----------------------------------------------------------------------------
variable "enable_resource_sharing" {
  type        = bool
  default     = false
  description = "Enable AWS RAM resource sharing for Transit Gateway"
}

variable "ram_principals" {
  type        = list(string)
  default     = []
  description = "List of AWS principals (account IDs or Organization ARN) to share Transit Gateway with"
}

variable "ram_allow_external_principals" {
  type        = bool
  default     = false
  description = "Whether principals outside your organization can be associated with a resource share"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources"
}
