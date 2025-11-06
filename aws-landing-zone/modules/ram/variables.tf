variable "transit_gateway_share_name" {
  description = "Name for the Transit Gateway RAM share"
  type        = string
  default     = ""
}

variable "route53_profile_share_name" {
  description = "Name for the Route53 Profile RAM share"
  type        = string
  default     = ""
}

variable "query_logging_share_name" {
  description = "Name for the Route53 Resolver Query Logging RAM share"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
  default     = "pb"
}

variable "resource_arns" {
  description = "Map of Amazon Resource Names (ARNs) to share with principals"
  type        = map(string)
}

variable "query_logging_arns" {
  description = "List of Route53 Resolver Query Logging resource ARNs to share via RAM"
  type        = list(string)
  default     = []
}

variable "share_with_organization" {
  description = "Whether to share resources with the entire organization"
  type        = bool
  default     = false
}

variable "share_with_organizational_units" {
  description = "List of Organization Unit ARNs to share resources with"
  type        = list(string)
  default     = []
}

variable "share_with_accounts" {
  description = "List of AWS Account IDs to share resources with"
  type        = list(string)
  default     = []
}

variable "share_with_organizations" {
  description = "List of Organization IDs to share resources with (format: o-xxxxxxxxxx)"
  type        = list(string)
  default     = []
}

variable "allow_external_principals" {
  description = "Whether to allow sharing with principals outside your organization"
  type        = bool
  default     = true
}

variable "allow_sharing_with_anyone" {
  description = "Whether to allow sharing with anyone (any AWS accounts, roles, and users)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
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
