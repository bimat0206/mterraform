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
  description = "Service name (e.g., api, web). If empty, will use 'securityhub'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# Security Hub Configuration
# -----------------------------------------------------------------------------
variable "enable_security_hub" {
  type        = bool
  default     = true
  description = "Enable AWS Security Hub"
}

variable "enable_default_standards" {
  type        = bool
  default     = true
  description = "Enable Security Hub default standards"
}

variable "control_finding_generator" {
  type        = string
  default     = "SECURITY_CONTROL"
  description = "Control finding generator: STANDARD_CONTROL or SECURITY_CONTROL"

  validation {
    condition     = contains(["STANDARD_CONTROL", "SECURITY_CONTROL"], var.control_finding_generator)
    error_message = "Must be STANDARD_CONTROL or SECURITY_CONTROL"
  }
}

# -----------------------------------------------------------------------------
# Organization Configuration
# -----------------------------------------------------------------------------
variable "enable_organization_admin_account" {
  type        = bool
  default     = true
  description = "Enable this account as the Security Hub delegated administrator"
}

variable "auto_enable_organization_members" {
  type        = bool
  default     = true
  description = "Automatically enable Security Hub for new organization members"
}

variable "auto_enable_default_standards" {
  type        = bool
  default     = true
  description = "Automatically enable default standards for new members"
}

# -----------------------------------------------------------------------------
# Security Standards
# -----------------------------------------------------------------------------
variable "enable_cis_standard" {
  type        = bool
  default     = true
  description = "Enable CIS AWS Foundations Benchmark standard"
}

variable "cis_standard_version" {
  type        = string
  default     = "1.4.0"
  description = "Version of CIS standard (1.2.0, 1.4.0)"
}

variable "enable_aws_foundational_standard" {
  type        = bool
  default     = true
  description = "Enable AWS Foundational Security Best Practices standard"
}

variable "aws_foundational_standard_version" {
  type        = string
  default     = "1.0.0"
  description = "Version of AWS Foundational Security Best Practices"
}

variable "enable_pci_dss_standard" {
  type        = bool
  default     = false
  description = "Enable PCI DSS standard"
}

variable "pci_dss_standard_version" {
  type        = string
  default     = "3.2.1"
  description = "Version of PCI DSS standard"
}

variable "enable_nist_standard" {
  type        = bool
  default     = false
  description = "Enable NIST SP 800-53 Rev. 5 standard"
}

variable "nist_standard_version" {
  type        = string
  default     = "5.0.0"
  description = "Version of NIST standard"
}

# -----------------------------------------------------------------------------
# Product Integrations
# -----------------------------------------------------------------------------
variable "enable_product_integrations" {
  type        = bool
  default     = true
  description = "Enable product integrations (GuardDuty, Config, IAM Access Analyzer, etc.)"
}

variable "product_arns" {
  type        = list(string)
  default     = []
  description = "List of product ARNs to integrate (auto-detected if empty)"
}

# -----------------------------------------------------------------------------
# CloudWatch Events
# -----------------------------------------------------------------------------
variable "enable_cloudwatch_events" {
  type        = bool
  default     = true
  description = "Create CloudWatch Event rule for Security Hub findings"
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
  description = "Send Security Hub findings to SNS topic"
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
  type        = list(string)
  default     = ["CRITICAL", "HIGH", "MEDIUM"]
  description = "Finding severity levels to notify on"
}

variable "workflow_status_filter" {
  type        = list(string)
  default     = ["NEW", "NOTIFIED"]
  description = "Workflow status filter for notifications"
}

# -----------------------------------------------------------------------------
# Finding Aggregation
# -----------------------------------------------------------------------------
variable "enable_finding_aggregator" {
  type        = bool
  default     = true
  description = "Enable cross-region finding aggregator"
}

variable "aggregator_linking_mode" {
  type        = string
  default     = "ALL_REGIONS"
  description = "Linking mode: ALL_REGIONS or SPECIFIED_REGIONS"

  validation {
    condition     = contains(["ALL_REGIONS", "SPECIFIED_REGIONS"], var.aggregator_linking_mode)
    error_message = "Must be ALL_REGIONS or SPECIFIED_REGIONS"
  }
}

variable "aggregator_regions" {
  type        = list(string)
  default     = []
  description = "Regions to aggregate (only used if linking_mode is SPECIFIED_REGIONS)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for all Security Hub resources"
}
