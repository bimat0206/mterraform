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
  description = "Workload name (e.g., app, platform)"
}

variable "service" {
  type        = string
  default     = ""
  description = "Service name (e.g., api, web). If empty, will use 'config'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# AWS Config Configuration
# -----------------------------------------------------------------------------
variable "enable_config" {
  type        = bool
  default     = true
  description = "Enable AWS Config configuration recorder"
}

variable "include_global_resource_types" {
  type        = bool
  default     = true
  description = "Record global resources (IAM, etc.) - should only be true in one region"
}

variable "all_supported_resource_types" {
  type        = bool
  default     = true
  description = "Record all supported resource types"
}

variable "resource_types" {
  type        = list(string)
  default     = []
  description = "List of resource types to record (only used if all_supported_resource_types is false)"
}

# -----------------------------------------------------------------------------
# S3 Bucket Configuration
# -----------------------------------------------------------------------------
variable "create_s3_bucket" {
  type        = bool
  default     = true
  description = "Create S3 bucket for Config delivery channel"
}

variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket name for Config (auto-generated if empty)"
}

variable "s3_bucket_lifecycle_days" {
  type        = number
  default     = 2555
  description = "Number of days to retain Config snapshots (7 years = 2555 days for compliance)"
}

variable "s3_key_prefix" {
  type        = string
  default     = "config"
  description = "S3 key prefix for Config deliveries"
}

# -----------------------------------------------------------------------------
# SNS Configuration
# -----------------------------------------------------------------------------
variable "create_sns_topic" {
  type        = bool
  default     = true
  description = "Create SNS topic for Config notifications"
}

variable "sns_topic_name" {
  type        = string
  default     = ""
  description = "SNS topic name (auto-generated if empty)"
}

variable "sns_email_subscriptions" {
  type        = list(string)
  default     = []
  description = "List of email addresses to subscribe to Config notifications"
}

# -----------------------------------------------------------------------------
# Organization Aggregator
# -----------------------------------------------------------------------------
variable "enable_organization_aggregator" {
  type        = bool
  default     = true
  description = "Enable organization-wide Config aggregator"
}

variable "aggregator_regions" {
  type        = list(string)
  default     = []
  description = "Regions to aggregate Config data from (empty = all enabled regions)"
}

# -----------------------------------------------------------------------------
# Config Rules
# -----------------------------------------------------------------------------
variable "enable_managed_rules" {
  type        = bool
  default     = true
  description = "Enable AWS managed Config rules"
}

variable "managed_rules" {
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = optional(map(string), {})
    enabled          = optional(bool, true)
  }))
  default     = {}
  description = "Map of AWS managed Config rules to enable"
}

# -----------------------------------------------------------------------------
# Recording Configuration
# -----------------------------------------------------------------------------
variable "recording_frequency" {
  type        = string
  default     = "CONTINUOUS"
  description = "Recording frequency: CONTINUOUS or DAILY"

  validation {
    condition     = contains(["CONTINUOUS", "DAILY"], var.recording_frequency)
    error_message = "Recording frequency must be CONTINUOUS or DAILY"
  }
}

# -----------------------------------------------------------------------------
# IAM Role
# -----------------------------------------------------------------------------
variable "create_iam_role" {
  type        = bool
  default     = true
  description = "Create IAM role for Config"
}

variable "iam_role_arn" {
  type        = string
  default     = ""
  description = "Existing IAM role ARN for Config (only used if create_iam_role is false)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for all Config resources"
}
