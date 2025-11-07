# -----------------------------------------------------------------------------
# Detector Outputs
# -----------------------------------------------------------------------------
output "detector_id" {
  description = "ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}

output "detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].arn : null
}

output "account_id" {
  description = "AWS account ID"
  value       = local.account_id
}

# -----------------------------------------------------------------------------
# S3 Bucket Outputs
# -----------------------------------------------------------------------------
output "s3_bucket_id" {
  description = "ID of the S3 bucket for findings export"
  value       = var.enable_guardduty && var.enable_s3_export ? aws_s3_bucket.findings[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for findings export"
  value       = var.enable_guardduty && var.enable_s3_export ? aws_s3_bucket.findings[0].arn : null
}

# -----------------------------------------------------------------------------
# SNS Topic Outputs
# -----------------------------------------------------------------------------
output "sns_topic_arn" {
  description = "ARN of the SNS topic for findings"
  value       = var.enable_guardduty && var.enable_sns_notifications ? aws_sns_topic.findings[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for findings"
  value       = var.enable_guardduty && var.enable_sns_notifications ? aws_sns_topic.findings[0].name : null
}

# -----------------------------------------------------------------------------
# CloudWatch Event Rule Outputs
# -----------------------------------------------------------------------------
output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event rule"
  value       = var.enable_guardduty && var.enable_cloudwatch_events ? aws_cloudwatch_event_rule.guardduty_findings[0].arn : null
}

output "cloudwatch_event_rule_name" {
  description = "Name of the CloudWatch Event rule"
  value       = var.enable_guardduty && var.enable_cloudwatch_events ? aws_cloudwatch_event_rule.guardduty_findings[0].name : null
}

# -----------------------------------------------------------------------------
# Protection Features Outputs
# -----------------------------------------------------------------------------
output "enabled_features" {
  description = "List of enabled GuardDuty protection features"
  value = var.enable_guardduty ? {
    s3_protection         = var.enable_s3_protection
    eks_protection        = var.enable_eks_protection
    malware_protection    = var.enable_malware_protection
    rds_protection        = var.enable_rds_protection
    lambda_protection     = var.enable_lambda_protection
  } : null
}

output "is_organization_admin" {
  description = "Whether this account is the GuardDuty delegated administrator"
  value       = var.enable_guardduty && var.enable_organization_admin_account
}

output "auto_enable_members" {
  description = "Whether GuardDuty auto-enables for new organization members"
  value       = var.enable_guardduty && var.auto_enable_organization_members
}

# -----------------------------------------------------------------------------
# Utility Outputs
# -----------------------------------------------------------------------------
output "guardduty_console_url" {
  description = "URL to view GuardDuty in AWS Console"
  value       = "https://${local.region}.console.aws.amazon.com/guardduty/home?region=${local.region}#/findings"
}

output "finding_publishing_frequency" {
  description = "How often findings are published"
  value       = var.enable_guardduty ? var.finding_publishing_frequency : null
}
