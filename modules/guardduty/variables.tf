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
  description = "Service name (e.g., api, web). If empty, will use 'guardduty'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# GuardDuty Configuration
# -----------------------------------------------------------------------------
variable "enable_guardduty" {
  type        = bool
  default     = true
  description = "Enable GuardDuty detector"
}

variable "finding_publishing_frequency" {
  type        = string
  default     = "FIFTEEN_MINUTES"
  description = "Frequency of notifications: FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS"
  }
}

# -----------------------------------------------------------------------------
# Protection Features
# -----------------------------------------------------------------------------
variable "enable_s3_protection" {
  type        = bool
  default     = true
  description = "Enable S3 Protection (monitors S3 data events)"
}

variable "enable_eks_protection" {
  type        = bool
  default     = true
  description = "Enable EKS Protection (monitors EKS audit logs)"
}

variable "enable_malware_protection" {
  type        = bool
  default     = true
  description = "Enable Malware Protection (scans EBS volumes)"
}

variable "enable_rds_protection" {
  type        = bool
  default     = true
  description = "Enable RDS Protection (monitors RDS login activity)"
}

variable "enable_lambda_protection" {
  type        = bool
  default     = true
  description = "Enable Lambda Protection (monitors Lambda network activity)"
}

# -----------------------------------------------------------------------------
# Organization Configuration
# -----------------------------------------------------------------------------
variable "enable_organization_admin_account" {
  type        = bool
  default     = true
  description = "Enable this account as the GuardDuty delegated administrator"
}

variable "auto_enable_organization_members" {
  type        = bool
  default     = true
  description = "Automatically enable GuardDuty for new organization members"
}

# -----------------------------------------------------------------------------
# Findings Export to S3
# -----------------------------------------------------------------------------
variable "enable_s3_export" {
  type        = bool
  default     = true
  description = "Export findings to S3 bucket"
}

variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket name for findings export (auto-generated if empty)"
}

variable "s3_key_prefix" {
  type        = string
  default     = "guardduty"
  description = "S3 key prefix for findings export"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "KMS key ARN for S3 encryption (uses AWS managed key if empty)"
}

# -----------------------------------------------------------------------------
# CloudWatch Events
# -----------------------------------------------------------------------------
variable "enable_cloudwatch_events" {
  type        = bool
  default     = true
  description = "Create CloudWatch Event rule for GuardDuty findings"
}

variable "cloudwatch_event_rule_pattern" {
  type        = any
  default     = null
  description = "Custom CloudWatch Event pattern (uses default if null)"
}

# -----------------------------------------------------------------------------
# SNS Notifications
# -----------------------------------------------------------------------------
variable "enable_sns_notifications" {
  type        = bool
  default     = true
  description = "Send GuardDuty findings to SNS topic"
}

variable "sns_topic_name" {
  type        = string
  default     = ""
  description = "SNS topic name for findings (auto-generated if empty)"
}

variable "sns_email_subscriptions" {
  type        = list(string)
  default     = []
  description = "List of email addresses for finding notifications"
}

variable "finding_severity_filter" {
  type        = list(number)
  default     = [4, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5, 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9]
  description = "Minimum severity for notifications (4-8.9 = medium to high, default: 4+)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for all GuardDuty resources"
}
