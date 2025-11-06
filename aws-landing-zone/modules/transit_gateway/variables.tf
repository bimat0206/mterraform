variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "The name must be between 1 and 255 characters."
  }
}

variable "amazon_side_asn" {
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session. Valid values are 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs."
  type        = number
  default     = 64512
  
  validation {
    condition     = (
      (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) || 
      (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    )
    error_message = "The amazon_side_asn must be in the range of 64512-65534 for 16-bit ASNs or 4200000000-4294967294 for 32-bit ASNs."
  }
}

variable "enable_auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted. When enabled, all VPC attachment requests to the Transit Gateway are automatically accepted."
  type        = bool
  default     = false
}

variable "enable_default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table. When disabled, you must explicitly associate attachments with route tables."
  type        = bool
  default     = false
}

variable "enable_default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table. When disabled, you must explicitly configure route propagation."
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the Transit Gateway. This enables DNS resolution for VPCs attached to the Transit Gateway."
  type        = bool
  default     = true
}

variable "enable_vpn_ecmp_support" {
  description = "Should be true to enable VPN Equal Cost Multipath Protocol support in the Transit Gateway. This enables multiple paths between the same two endpoints for load balancing and redundancy."
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the Transit Gateway. This appears in the AWS Console and helps identify the purpose of this Transit Gateway."
  type        = string
  default     = null
}

variable "vpc_attachments" {
  description = "Maps of VPC attachment configurations. Each entry represents a VPC to attach to the Transit Gateway."
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
    name       = string
    dns_support                    = optional(string, "enable")
    ipv6_support                   = optional(string, "disable")
    appliance_mode_support         = optional(string, "disable")
    default_route_table_association = optional(bool)
    default_route_table_propagation = optional(bool)
  }))
  default = {}
}

variable "route_tables" {
  description = "Maps of route table configurations. Each entry defines a Transit Gateway route table with its associations, propagations, and static routes."
  type = map(object({
    name = string
    associations = list(string)
    propagations = list(string)
    static_routes = list(object({
      cidr = string
      attachment_key = string
    }))
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for rt_key, rt in var.route_tables : 
        length(rt.name) > 0 && length(rt.name) <= 255
    ])
    error_message = "All route table names must be between 1 and 255 characters."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources created by this module. These tags will be applied to all resources unless overridden by resource-specific tags."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "princebank"
}

variable "cost_center" {
  description = "Cost center for the resource"
  type        = string
  default     = "landing-zone"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "landing-zone"
}

variable "enable_flow_logs" {
  description = "Whether to enable flow logs for Transit Gateway and its attachments"
  type        = bool
  default     = true  # Enable by default
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination. Only cloud-watch-logs is supported"
  type        = string
  default     = "cloud-watch-logs"
  
  validation {
    condition     = var.flow_log_destination_type == "cloud-watch-logs"
    error_message = "Only cloud-watch-logs is supported for flow_log_destination_type."
  }
}

variable "flow_log_max_aggregation_interval" {
  description = "Maximum interval in seconds for capturing and aggregating flows. Valid values: 60, 600"
  type        = number
  default     = 60
  
  validation {
    condition     = contains([60, 600], var.flow_log_max_aggregation_interval)
    error_message = "Valid values for flow_log_max_aggregation_interval are: 60 (1 minute), 600 (10 minutes)."
  }
}

variable "flow_log_retention_in_days" {
  description = "Specifies the number of days to retain log events in the CloudWatch log group"
  type        = number
  default     = 30
  
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_log_retention_in_days)
    error_message = "Valid values for flow_log_retention_in_days are: 0 (never expire), 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

# S3 bucket variables removed as we're only using CloudWatch logs
variable "vpn_attachments" {
  type = map(any)
  default = {}
  description = "Map of VPN attachment configurations"
}