# -----------------------------------------------------------------------------
# Configuration Recorder Outputs
# -----------------------------------------------------------------------------
output "configuration_recorder_id" {
  description = "ID of the AWS Config configuration recorder"
  value       = var.enable_config ? aws_config_configuration_recorder.this[0].id : null
}

output "configuration_recorder_arn" {
  description = "ARN of the AWS Config configuration recorder"
  value       = var.enable_config ? "arn:${local.partition}:config:${local.region}:${local.account_id}:config-recorder/${aws_config_configuration_recorder.this[0].name}" : null
}

output "delivery_channel_id" {
  description = "ID of the AWS Config delivery channel"
  value       = var.enable_config ? aws_config_delivery_channel.this[0].id : null
}

# -----------------------------------------------------------------------------
# S3 Bucket Outputs
# -----------------------------------------------------------------------------
output "s3_bucket_id" {
  description = "ID of the S3 bucket for Config delivery"
  value       = var.create_s3_bucket ? aws_s3_bucket.config[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Config delivery"
  value       = var.create_s3_bucket ? aws_s3_bucket.config[0].arn : null
}

# -----------------------------------------------------------------------------
# SNS Topic Outputs
# -----------------------------------------------------------------------------
output "sns_topic_arn" {
  description = "ARN of the SNS topic for Config notifications"
  value       = var.create_sns_topic ? aws_sns_topic.config[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for Config notifications"
  value       = var.create_sns_topic ? aws_sns_topic.config[0].name : null
}

# -----------------------------------------------------------------------------
# Organization Aggregator Outputs
# -----------------------------------------------------------------------------
output "organization_aggregator_arn" {
  description = "ARN of the organization aggregator"
  value       = var.enable_organization_aggregator ? aws_config_configuration_aggregator.organization[0].arn : null
}

output "organization_aggregator_name" {
  description = "Name of the organization aggregator"
  value       = var.enable_organization_aggregator ? aws_config_configuration_aggregator.organization[0].name : null
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------
output "iam_role_arn" {
  description = "ARN of the IAM role for AWS Config"
  value       = var.create_iam_role ? aws_iam_role.config[0].arn : var.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role for AWS Config"
  value       = var.create_iam_role ? aws_iam_role.config[0].name : null
}

# -----------------------------------------------------------------------------
# Config Rules Outputs
# -----------------------------------------------------------------------------
output "config_rule_arns" {
  description = "Map of Config rule names to ARNs"
  value = var.enable_managed_rules ? {
    for k, v in aws_config_config_rule.managed : k => v.arn
  } : {}
}

output "enabled_rules_count" {
  description = "Number of enabled Config rules"
  value       = var.enable_managed_rules ? length(aws_config_config_rule.managed) : 0
}

# -----------------------------------------------------------------------------
# Utility Outputs
# -----------------------------------------------------------------------------
output "config_console_url" {
  description = "URL to view Config in AWS Console"
  value       = "https://${local.region}.console.aws.amazon.com/config/home?region=${local.region}#/dashboard"
}

output "is_recording" {
  description = "Whether Config recorder is enabled"
  value       = var.enable_config
}
