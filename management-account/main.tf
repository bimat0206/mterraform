# -----------------------------------------------------------------------------
# IAM Identity Center Module
# -----------------------------------------------------------------------------
module "identity_center" {
  count  = var.identity_center_enabled ? 1 : 0
  source = "../modules/iam-identity-center"

  # Identity Store Configuration
  create_identity_store_users  = var.create_identity_store_users
  create_identity_store_groups = var.create_identity_store_groups

  # Users and Groups
  users  = var.identity_center_users
  groups = var.identity_center_groups

  # Permission Sets
  permission_sets = var.identity_center_permission_sets

  # Account Assignments
  account_assignments = var.identity_center_account_assignments

  # External Identity Provider
  external_idp_enabled = var.external_idp_enabled
  external_groups      = var.external_groups
  external_users       = var.external_users

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# AWS Config Module
# -----------------------------------------------------------------------------
module "config" {
  count  = var.config_enabled ? 1 : 0
  source = "../modules/config"

  # Naming
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  identifier  = var.config_identifier

  # Config Settings
  enable_config                   = var.config_enable_recorder
  include_global_resource_types   = var.config_include_global_resources
  all_supported_resource_types    = var.config_all_supported_resources
  resource_types                  = var.config_resource_types
  recording_frequency             = var.config_recording_frequency

  # Organization Aggregator
  enable_organization_aggregator = var.config_enable_organization_aggregator
  aggregator_regions             = var.config_aggregator_regions

  # S3 Bucket
  create_s3_bucket         = var.config_create_s3_bucket
  s3_bucket_name           = var.config_s3_bucket_name
  s3_bucket_lifecycle_days = var.config_s3_lifecycle_days
  s3_key_prefix            = var.config_s3_key_prefix

  # SNS Notifications
  create_sns_topic        = var.config_create_sns_topic
  sns_topic_name          = var.config_sns_topic_name
  sns_email_subscriptions = var.config_sns_email_subscriptions

  # Config Rules
  enable_managed_rules = var.config_enable_managed_rules
  managed_rules        = var.config_managed_rules

  # IAM Role
  create_iam_role = var.config_create_iam_role
  iam_role_arn    = var.config_iam_role_arn

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# AWS GuardDuty Module
# -----------------------------------------------------------------------------
module "guardduty" {
  count  = var.guardduty_enabled ? 1 : 0
  source = "../modules/guardduty"

  # Naming
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  identifier  = var.guardduty_identifier

  # GuardDuty Configuration
  enable_guardduty             = var.guardduty_enable_detector
  finding_publishing_frequency = var.guardduty_finding_frequency

  # Protection Features
  enable_s3_protection       = var.guardduty_enable_s3_protection
  enable_eks_protection      = var.guardduty_enable_eks_protection
  enable_malware_protection  = var.guardduty_enable_malware_protection
  enable_rds_protection      = var.guardduty_enable_rds_protection
  enable_lambda_protection   = var.guardduty_enable_lambda_protection

  # Organization Configuration
  enable_organization_admin_account = var.guardduty_enable_organization_admin
  auto_enable_organization_members  = var.guardduty_auto_enable_members

  # Findings Export
  enable_s3_export = var.guardduty_enable_s3_export
  s3_bucket_name   = var.guardduty_s3_bucket_name
  s3_key_prefix    = var.guardduty_s3_key_prefix
  kms_key_arn      = var.guardduty_kms_key_arn

  # CloudWatch Events
  enable_cloudwatch_events        = var.guardduty_enable_cloudwatch_events
  cloudwatch_event_rule_pattern   = var.guardduty_event_rule_pattern

  # SNS Notifications
  enable_sns_notifications = var.guardduty_enable_sns_notifications
  sns_topic_name           = var.guardduty_sns_topic_name
  sns_email_subscriptions  = var.guardduty_sns_email_subscriptions
  finding_severity_filter  = var.guardduty_severity_filter

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# AWS Security Hub Module
# -----------------------------------------------------------------------------
module "securityhub" {
  count  = var.securityhub_enabled ? 1 : 0
  source = "../modules/securityhub"

  # Naming
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  identifier  = var.securityhub_identifier

  # Security Hub Configuration
  enable_security_hub       = var.securityhub_enable_account
  enable_default_standards  = var.securityhub_enable_default_standards
  control_finding_generator = var.securityhub_control_finding_generator

  # Organization Configuration
  enable_organization_admin_account = var.securityhub_enable_organization_admin
  auto_enable_organization_members  = var.securityhub_auto_enable_members
  auto_enable_default_standards     = var.securityhub_auto_enable_standards

  # Security Standards
  enable_cis_standard                  = var.securityhub_enable_cis_standard
  cis_standard_version                 = var.securityhub_cis_version
  enable_aws_foundational_standard     = var.securityhub_enable_aws_foundational_standard
  aws_foundational_standard_version    = var.securityhub_aws_foundational_version
  enable_pci_dss_standard              = var.securityhub_enable_pci_dss_standard
  pci_dss_standard_version             = var.securityhub_pci_dss_version
  enable_nist_standard                 = var.securityhub_enable_nist_standard
  nist_standard_version                = var.securityhub_nist_version

  # Product Integrations
  enable_product_integrations = var.securityhub_enable_product_integrations
  product_arns                = var.securityhub_product_arns

  # Finding Aggregator
  enable_finding_aggregator  = var.securityhub_enable_finding_aggregator
  aggregator_linking_mode    = var.securityhub_aggregator_linking_mode
  aggregator_regions         = var.securityhub_aggregator_regions

  # CloudWatch Events
  enable_cloudwatch_events      = var.securityhub_enable_cloudwatch_events
  cloudwatch_event_rule_pattern = var.securityhub_event_rule_pattern

  # SNS Notifications
  enable_sns_notifications = var.securityhub_enable_sns_notifications
  sns_topic_name           = var.securityhub_sns_topic_name
  sns_email_subscriptions  = var.securityhub_sns_email_subscriptions
  finding_severity_filter  = var.securityhub_severity_filter
  workflow_status_filter   = var.securityhub_workflow_status_filter

  # Tags
  tags = local.common_tags

  # Ensure GuardDuty and Config are enabled first for product integrations
  depends_on = [
    module.guardduty,
    module.config
  ]
}
