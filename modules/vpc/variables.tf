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

variable "az_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones to use for subnets"
  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6
    error_message = "az_count must be between 1 and 6"
  }
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for private subnets"
}
