variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "enable" {
  description = "Flag to enable/disable the Route53 profiles"
  type        = bool
  default     = true
}

variable "primary_vpc_id" {
  description = "ID of the primary VPC where Route53 resolver will be configured"
  type        = string
}

variable "additional_vpc_ids" {
  description = "List of additional VPC IDs to associate with Route53 resolver configuration"
  type        = list(string)
  default     = []
}

variable "autodefined_reverse_flag" {
  description = "Flag to enable/disable autodefined reverse DNS resolution"
  type        = string
  default     = "DISABLE"
}

variable "private_hosted_zones" {
  description = "List of private hosted zone IDs to associate with all VPCs"
  type        = list(string)
  default     = []
}

variable "resolver_rules" {
  description = "List of resolver rule IDs to associate with all VPCs"
  type        = list(string)
  default     = []
}

variable "skip_zone_associations" {
  description = "List of zone_ids to skip when creating hosted zone associations with the Route53 Profile"
  type        = list(string)
  default     = []
}

variable "skip_rule_associations" {
  description = "List of resolver_rule_ids to skip when creating resolver rule associations with the Route53 Profile"
  type        = list(string)
  default     = []
}

variable "skip_vpc_associations" {
  description = "List of vpc_ids to skip when associating with the Route53 Profile"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS account ID where resources will be created"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner name for tagging"
  type        = string
  default     = "princebank"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_query_logging" {
  description = "Enable Route53 Resolver query logging"
  type        = bool
  default     = false
}

variable "query_log_retention_days" {
  description = "Number of days to retain Route53 Resolver query logs"
  type        = number
  default     = 30
}