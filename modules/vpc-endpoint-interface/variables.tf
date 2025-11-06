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
  description = "Service name override. Defaults to 'vpce-if' if not provided"
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
# VPC Configuration
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID where endpoints will be created"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of the VPC (for security group rules)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where interface endpoints will be created"
}

# -----------------------------------------------------------------------------
# Interface Endpoint Configuration
# -----------------------------------------------------------------------------
variable "endpoints" {
  type        = map(bool)
  default     = {}
  description = "Map of AWS service names to create interface endpoints for (e.g., { ec2 = true, ssm = true })"
}

variable "private_dns_enabled" {
  type        = bool
  default     = true
  description = "Enable private DNS for interface endpoints"
}

# -----------------------------------------------------------------------------
# Security Group Configuration
# -----------------------------------------------------------------------------
variable "create_security_group" {
  type        = bool
  default     = true
  description = "Create a security group for interface endpoints"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to attach to endpoints (used if create_security_group = false)"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "Additional CIDR blocks allowed to access endpoints (VPC CIDR is auto-included)"
}

variable "security_group_description" {
  type        = string
  default     = "Security group for VPC interface endpoints"
  description = "Description for the security group"
}
