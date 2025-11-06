variable "name_prefix" {
  description = "Global prefix for all resources (e.g., 'pb-network')"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC where Route 53 Resolver endpoints will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where resolver endpoints will be created"
  type        = list(string)
}

variable "inbound_resolver_enabled" {
  description = "Whether to create inbound resolver endpoint"
  type        = bool
  default     = false
}

variable "outbound_resolver_enabled" {
  description = "Whether to create outbound resolver endpoint"
  type        = bool
  default     = false
}

variable "target_ips" {
  description = "List of target IP addresses for outbound resolver rules"
  type        = list(object({
    ip   = string
    port = number
  }))
  default = []
}

variable "resolver_rules_domain_names" {
  description = "List of domain names for resolver rules"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the resources"
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
  default     = ""
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

variable "additional_vpc_ids" {
  description = "List of additional VPC IDs to associate with the query logging config"
  type        = list(string)
  default     = []
}


