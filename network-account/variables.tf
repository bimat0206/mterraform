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
# VPC configuration
# -----------------------------------------------------------------------------
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "vpc_az_count" {
  type        = number
  description = "Number of Availability Zones for VPC subnets"
  default     = 2
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for VPC private subnets"
  default     = true
}

# -----------------------------------------------------------------------------
# ACM configuration
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
