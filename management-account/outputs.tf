# -----------------------------------------------------------------------------
# IAM Identity Center Outputs
# -----------------------------------------------------------------------------
output "identity_center_instance_arn" {
  description = "ARN of the IAM Identity Center instance (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].instance_arn : null
}

output "identity_center_identity_store_id" {
  description = "ID of the Identity Store (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].identity_store_id : null
}

output "identity_center_permission_set_arns" {
  description = "Map of permission set names to ARNs (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].permission_set_arns : null
}

output "identity_center_permission_set_names" {
  description = "List of permission set names (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].permission_set_names : null
}

output "identity_center_group_ids" {
  description = "Map of group names to group IDs (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].group_ids : null
}

output "identity_center_user_ids" {
  description = "Map of user names to user IDs (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].user_ids : null
}

output "identity_center_account_assignments" {
  description = "Map of account assignments (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].account_assignments : null
}

output "identity_center_account_assignment_count" {
  description = "Total number of account assignments (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].account_assignment_count : null
}

output "identity_center_permission_set_count" {
  description = "Total number of permission sets (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].permission_set_count : null
}

output "identity_center_internal_group_count" {
  description = "Total number of internal Identity Store groups (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].internal_group_count : null
}

output "identity_center_internal_user_count" {
  description = "Total number of internal Identity Store users (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].internal_user_count : null
}

output "identity_center_list_instances_command" {
  description = "Command to list IAM Identity Center instances (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].list_instances_command : null
}

output "identity_center_list_permission_sets_command" {
  description = "Command to list permission sets (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].list_permission_sets_command : null
}

output "identity_center_list_account_assignments_command" {
  description = "Command to list account assignments (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].list_account_assignments_command : null
}

output "identity_center_aws_sso_portal_url" {
  description = "AWS SSO Portal URL information (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].aws_sso_portal_url : null
}

# -----------------------------------------------------------------------------
# AWS Config Outputs
# -----------------------------------------------------------------------------
output "config_configuration_recorder_id" {
  description = "ID of the AWS Config configuration recorder (if enabled)"
  value       = var.config_enabled ? module.config[0].configuration_recorder_id : null
}

output "config_configuration_recorder_arn" {
  description = "ARN of the AWS Config configuration recorder (if enabled)"
  value       = var.config_enabled ? module.config[0].configuration_recorder_arn : null
}

output "config_s3_bucket_id" {
  description = "ID of the S3 bucket for Config delivery (if enabled)"
  value       = var.config_enabled ? module.config[0].s3_bucket_id : null
}

output "config_s3_bucket_arn" {
  description = "ARN of the S3 bucket for Config delivery (if enabled)"
  value       = var.config_enabled ? module.config[0].s3_bucket_arn : null
}

output "config_sns_topic_arn" {
  description = "ARN of the SNS topic for Config notifications (if enabled)"
  value       = var.config_enabled ? module.config[0].sns_topic_arn : null
}

output "config_organization_aggregator_arn" {
  description = "ARN of the organization aggregator (if enabled)"
  value       = var.config_enabled ? module.config[0].organization_aggregator_arn : null
}

output "config_enabled_rules_count" {
  description = "Number of enabled Config rules (if enabled)"
  value       = var.config_enabled ? module.config[0].enabled_rules_count : null
}

output "config_console_url" {
  description = "URL to view Config in AWS Console (if enabled)"
  value       = var.config_enabled ? module.config[0].config_console_url : null
}

# -----------------------------------------------------------------------------
# AWS GuardDuty Outputs
# -----------------------------------------------------------------------------
output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].detector_id : null
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].detector_arn : null
}

output "guardduty_s3_bucket_id" {
  description = "ID of the S3 bucket for findings export (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].s3_bucket_id : null
}

output "guardduty_s3_bucket_arn" {
  description = "ARN of the S3 bucket for findings export (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].s3_bucket_arn : null
}

output "guardduty_sns_topic_arn" {
  description = "ARN of the SNS topic for findings (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].sns_topic_arn : null
}

output "guardduty_enabled_features" {
  description = "List of enabled GuardDuty protection features (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].enabled_features : null
}

output "guardduty_console_url" {
  description = "URL to view GuardDuty in AWS Console (if enabled)"
  value       = var.guardduty_enabled ? module.guardduty[0].guardduty_console_url : null
}

# -----------------------------------------------------------------------------
# AWS Security Hub Outputs
# -----------------------------------------------------------------------------
output "securityhub_security_hub_id" {
  description = "ID of the Security Hub account (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].security_hub_id : null
}

output "securityhub_security_hub_arn" {
  description = "ARN of the Security Hub account (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].security_hub_arn : null
}

output "securityhub_enabled_standards" {
  description = "Map of enabled security standards (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].enabled_standards : null
}

output "securityhub_finding_aggregator_arn" {
  description = "ARN of the finding aggregator (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].finding_aggregator_arn : null
}

output "securityhub_sns_topic_arn" {
  description = "ARN of the SNS topic for findings (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].sns_topic_arn : null
}

output "securityhub_product_subscriptions_count" {
  description = "Number of product subscriptions (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].product_subscriptions_count : null
}

output "securityhub_console_url" {
  description = "URL to view Security Hub in AWS Console (if enabled)"
  value       = var.securityhub_enabled ? module.securityhub[0].securityhub_console_url : null
}
