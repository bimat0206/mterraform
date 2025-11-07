# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for management account resources"
}

variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming"
}

variable "environment" {
  type        = string
  default     = "management"
  description = "Environment name"
}

variable "workload" {
  type        = string
  default     = "org"
  description = "Workload name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# IAM Identity Center Variables
# -----------------------------------------------------------------------------
variable "identity_center_enabled" {
  type        = bool
  default     = false
  description = "Enable IAM Identity Center configuration"
}

variable "create_identity_store_users" {
  type        = bool
  default     = false
  description = "Create users in Identity Center Identity Store"
}

variable "create_identity_store_groups" {
  type        = bool
  default     = false
  description = "Create groups in Identity Center Identity Store"
}

variable "identity_center_users" {
  type = map(object({
    user_name    = string
    display_name = string
    email        = string
    first_name   = string
    last_name    = string
    group_memberships = optional(list(string), [])
  }))
  default     = {}
  description = "Map of users to create in Identity Center Identity Store"
}

variable "identity_center_groups" {
  type = map(object({
    display_name = string
    description  = string
  }))
  default     = {}
  description = "Map of groups to create in Identity Center Identity Store"
}

variable "identity_center_permission_sets" {
  type = map(object({
    description          = string
    session_duration     = optional(string, "PT1H")
    relay_state          = optional(string, "")
    aws_managed_policies = optional(list(string), [])
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])
    inline_policy = optional(string, "")
    permissions_boundary = optional(object({
      customer_managed_policy_reference = optional(object({
        name = string
        path = optional(string, "/")
      }), null)
      managed_policy_arn = optional(string, "")
    }), null)
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of permission sets to create"
}

variable "identity_center_account_assignments" {
  type = map(object({
    account_id       = string
    permission_set   = string
    principal_type   = string
    principal_name   = string
  }))
  default     = {}
  description = "Map of account assignments"
}

variable "external_idp_enabled" {
  type        = bool
  default     = false
  description = "Whether using external identity provider"
}

variable "external_groups" {
  type = map(object({
    display_name = string
  }))
  default     = {}
  description = "Map of external IdP groups"
}

variable "external_users" {
  type = map(object({
    user_name = string
  }))
  default     = {}
  description = "Map of external IdP users"
}

# -----------------------------------------------------------------------------
# AWS Config Variables
# -----------------------------------------------------------------------------
variable "config_enabled" {
  type        = bool
  default     = false
  description = "Enable AWS Config"
}

variable "config_identifier" {
  type        = string
  default     = "01"
  description = "Resource identifier for Config"
}

variable "config_enable_recorder" {
  type        = bool
  default     = true
  description = "Enable Config recorder"
}

variable "config_include_global_resources" {
  type        = bool
  default     = true
  description = "Record global resources (IAM, etc.)"
}

variable "config_all_supported_resources" {
  type        = bool
  default     = true
  description = "Record all supported resource types"
}

variable "config_resource_types" {
  type        = list(string)
  default     = []
  description = "Specific resource types to record"
}

variable "config_recording_frequency" {
  type        = string
  default     = "CONTINUOUS"
  description = "Recording frequency: CONTINUOUS or DAILY"
}

variable "config_enable_organization_aggregator" {
  type        = bool
  default     = true
  description = "Enable organization aggregator"
}

variable "config_aggregator_regions" {
  type        = list(string)
  default     = []
  description = "Regions to aggregate (empty = all regions)"
}

variable "config_create_s3_bucket" {
  type        = bool
  default     = true
  description = "Create S3 bucket for Config"
}

variable "config_s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket name (auto-generated if empty)"
}

variable "config_s3_lifecycle_days" {
  type        = number
  default     = 2555
  description = "S3 lifecycle retention days (7 years)"
}

variable "config_s3_key_prefix" {
  type        = string
  default     = "config"
  description = "S3 key prefix"
}

variable "config_create_sns_topic" {
  type        = bool
  default     = true
  description = "Create SNS topic"
}

variable "config_sns_topic_name" {
  type        = string
  default     = ""
  description = "SNS topic name (auto-generated if empty)"
}

variable "config_sns_email_subscriptions" {
  type        = list(string)
  default     = []
  description = "Email addresses for Config notifications"
}

variable "config_enable_managed_rules" {
  type        = bool
  default     = true
  description = "Enable AWS managed Config rules"
}

variable "config_managed_rules" {
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = optional(map(string), {})
    enabled          = optional(bool, true)
  }))
  default     = {}
  description = "Config rules to enable"
}

variable "config_create_iam_role" {
  type        = bool
  default     = true
  description = "Create IAM role for Config"
}

variable "config_iam_role_arn" {
  type        = string
  default     = ""
  description = "Existing IAM role ARN"
}

# -----------------------------------------------------------------------------
# AWS GuardDuty Variables
# -----------------------------------------------------------------------------
variable "guardduty_enabled" {
  type        = bool
  default     = false
  description = "Enable AWS GuardDuty"
}

variable "guardduty_identifier" {
  type        = string
  default     = "01"
  description = "Resource identifier for GuardDuty"
}

variable "guardduty_enable_detector" {
  type        = bool
  default     = true
  description = "Enable GuardDuty detector"
}

variable "guardduty_finding_frequency" {
  type        = string
  default     = "FIFTEEN_MINUTES"
  description = "Finding publishing frequency"
}

variable "guardduty_enable_s3_protection" {
  type        = bool
  default     = true
  description = "Enable S3 Protection"
}

variable "guardduty_enable_eks_protection" {
  type        = bool
  default     = true
  description = "Enable EKS Protection"
}

variable "guardduty_enable_malware_protection" {
  type        = bool
  default     = true
  description = "Enable Malware Protection"
}

variable "guardduty_enable_rds_protection" {
  type        = bool
  default     = true
  description = "Enable RDS Protection"
}

variable "guardduty_enable_lambda_protection" {
  type        = bool
  default     = true
  description = "Enable Lambda Protection"
}

variable "guardduty_enable_organization_admin" {
  type        = bool
  default     = true
  description = "Enable organization admin account"
}

variable "guardduty_auto_enable_members" {
  type        = bool
  default     = true
  description = "Auto-enable for organization members"
}

variable "guardduty_enable_s3_export" {
  type        = bool
  default     = true
  description = "Export findings to S3"
}

variable "guardduty_s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket name (auto-generated if empty)"
}

variable "guardduty_s3_key_prefix" {
  type        = string
  default     = "guardduty"
  description = "S3 key prefix"
}

variable "guardduty_kms_key_arn" {
  type        = string
  default     = ""
  description = "KMS key ARN for encryption"
}

variable "guardduty_enable_cloudwatch_events" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Events"
}

variable "guardduty_event_rule_pattern" {
  type        = any
  default     = null
  description = "Custom CloudWatch Event pattern"
}

variable "guardduty_enable_sns_notifications" {
  type        = bool
  default     = true
  description = "Enable SNS notifications"
}

variable "guardduty_sns_topic_name" {
  type        = string
  default     = ""
  description = "SNS topic name (auto-generated if empty)"
}

variable "guardduty_sns_email_subscriptions" {
  type        = list(string)
  default     = []
  description = "Email addresses for GuardDuty notifications"
}

variable "guardduty_severity_filter" {
  type        = list(number)
  default     = [4, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5, 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9]
  description = "Severity filter for notifications"
}

# -----------------------------------------------------------------------------
# AWS Security Hub Variables
# -----------------------------------------------------------------------------
variable "securityhub_enabled" {
  type        = bool
  default     = false
  description = "Enable AWS Security Hub"
}

variable "securityhub_identifier" {
  type        = string
  default     = "01"
  description = "Resource identifier for Security Hub"
}

variable "securityhub_enable_account" {
  type        = bool
  default     = true
  description = "Enable Security Hub account"
}

variable "securityhub_enable_default_standards" {
  type        = bool
  default     = true
  description = "Enable default standards"
}

variable "securityhub_control_finding_generator" {
  type        = string
  default     = "SECURITY_CONTROL"
  description = "Control finding generator type"
}

variable "securityhub_enable_organization_admin" {
  type        = bool
  default     = true
  description = "Enable organization admin account"
}

variable "securityhub_auto_enable_members" {
  type        = bool
  default     = true
  description = "Auto-enable for organization members"
}

variable "securityhub_auto_enable_standards" {
  type        = bool
  default     = true
  description = "Auto-enable standards for members"
}

variable "securityhub_enable_cis_standard" {
  type        = bool
  default     = true
  description = "Enable CIS standard"
}

variable "securityhub_cis_version" {
  type        = string
  default     = "1.4.0"
  description = "CIS standard version"
}

variable "securityhub_enable_aws_foundational_standard" {
  type        = bool
  default     = true
  description = "Enable AWS Foundational standard"
}

variable "securityhub_aws_foundational_version" {
  type        = string
  default     = "1.0.0"
  description = "AWS Foundational standard version"
}

variable "securityhub_enable_pci_dss_standard" {
  type        = bool
  default     = false
  description = "Enable PCI DSS standard"
}

variable "securityhub_pci_dss_version" {
  type        = string
  default     = "3.2.1"
  description = "PCI DSS standard version"
}

variable "securityhub_enable_nist_standard" {
  type        = bool
  default     = false
  description = "Enable NIST standard"
}

variable "securityhub_nist_version" {
  type        = string
  default     = "5.0.0"
  description = "NIST standard version"
}

variable "securityhub_enable_product_integrations" {
  type        = bool
  default     = true
  description = "Enable product integrations"
}

variable "securityhub_product_arns" {
  type        = list(string)
  default     = []
  description = "Product ARNs to integrate"
}

variable "securityhub_enable_finding_aggregator" {
  type        = bool
  default     = true
  description = "Enable finding aggregator"
}

variable "securityhub_aggregator_linking_mode" {
  type        = string
  default     = "ALL_REGIONS"
  description = "Aggregator linking mode"
}

variable "securityhub_aggregator_regions" {
  type        = list(string)
  default     = []
  description = "Regions to aggregate"
}

variable "securityhub_enable_cloudwatch_events" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Events"
}

variable "securityhub_event_rule_pattern" {
  type        = any
  default     = null
  description = "Custom CloudWatch Event pattern"
}

variable "securityhub_enable_sns_notifications" {
  type        = bool
  default     = true
  description = "Enable SNS notifications"
}

variable "securityhub_sns_topic_name" {
  type        = string
  default     = ""
  description = "SNS topic name (auto-generated if empty)"
}

variable "securityhub_sns_email_subscriptions" {
  type        = list(string)
  default     = []
  description = "Email addresses for Security Hub notifications"
}

variable "securityhub_severity_filter" {
  type        = list(string)
  default     = ["CRITICAL", "HIGH", "MEDIUM"]
  description = "Severity filter for notifications"
}

variable "securityhub_workflow_status_filter" {
  type        = list(string)
  default     = ["NEW", "NOTIFIED"]
  description = "Workflow status filter"
}
