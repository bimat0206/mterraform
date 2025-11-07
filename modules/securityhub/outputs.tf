# -----------------------------------------------------------------------------
# Security Hub Account Outputs
# -----------------------------------------------------------------------------
output "security_hub_id" {
  description = "ID of the Security Hub account"
  value       = var.enable_security_hub ? aws_securityhub_account.this[0].id : null
}

output "security_hub_arn" {
  description = "ARN of the Security Hub account"
  value       = var.enable_security_hub ? aws_securityhub_account.this[0].arn : null
}

output "account_id" {
  description = "AWS account ID"
  value       = local.account_id
}

# -----------------------------------------------------------------------------
# Standards Outputs
# -----------------------------------------------------------------------------
output "enabled_standards" {
  description = "Map of enabled security standards"
  value = var.enable_security_hub ? {
    cis_foundations      = var.enable_cis_standard
    aws_foundational     = var.enable_aws_foundational_standard
    pci_dss             = var.enable_pci_dss_standard
    nist_800_53         = var.enable_nist_standard
  } : null
}

output "cis_standard_subscription_arn" {
  description = "ARN of CIS standard subscription"
  value       = var.enable_security_hub && var.enable_cis_standard ? aws_securityhub_standards_subscription.cis[0].standards_arn : null
}

output "aws_foundational_standard_subscription_arn" {
  description = "ARN of AWS Foundational standard subscription"
  value       = var.enable_security_hub && var.enable_aws_foundational_standard ? aws_securityhub_standards_subscription.aws_foundational[0].standards_arn : null
}

# -----------------------------------------------------------------------------
# Finding Aggregator Outputs
# -----------------------------------------------------------------------------
output "finding_aggregator_arn" {
  description = "ARN of the finding aggregator"
  value       = var.enable_security_hub && var.enable_finding_aggregator ? aws_securityhub_finding_aggregator.this[0].arn : null
}

output "finding_aggregator_linking_mode" {
  description = "Linking mode of the finding aggregator"
  value       = var.enable_security_hub && var.enable_finding_aggregator ? var.aggregator_linking_mode : null
}

# -----------------------------------------------------------------------------
# SNS Topic Outputs
# -----------------------------------------------------------------------------
output "sns_topic_arn" {
  description = "ARN of the SNS topic for findings"
  value       = var.enable_security_hub && var.enable_sns_notifications ? aws_sns_topic.findings[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for findings"
  value       = var.enable_security_hub && var.enable_sns_notifications ? aws_sns_topic.findings[0].name : null
}

# -----------------------------------------------------------------------------
# CloudWatch Event Rule Outputs
# -----------------------------------------------------------------------------
output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event rule"
  value       = var.enable_security_hub && var.enable_cloudwatch_events ? aws_cloudwatch_event_rule.securityhub_findings[0].arn : null
}

output "cloudwatch_event_rule_name" {
  description = "Name of the CloudWatch Event rule"
  value       = var.enable_security_hub && var.enable_cloudwatch_events ? aws_cloudwatch_event_rule.securityhub_findings[0].name : null
}

# -----------------------------------------------------------------------------
# Organization Configuration Outputs
# -----------------------------------------------------------------------------
output "is_organization_admin" {
  description = "Whether this account is the Security Hub delegated administrator"
  value       = var.enable_security_hub && var.enable_organization_admin_account
}

output "auto_enable_members" {
  description = "Whether Security Hub auto-enables for new organization members"
  value       = var.enable_security_hub && var.auto_enable_organization_members
}

output "auto_enable_standards" {
  description = "Whether default standards auto-enable for new members"
  value       = var.enable_security_hub && var.auto_enable_default_standards
}

# -----------------------------------------------------------------------------
# Product Integration Outputs
# -----------------------------------------------------------------------------
output "product_subscriptions" {
  description = "List of product ARNs subscribed to Security Hub"
  value       = var.enable_security_hub && var.enable_product_integrations ? local.default_product_arns : []
}

output "product_subscriptions_count" {
  description = "Number of product subscriptions"
  value       = var.enable_security_hub && var.enable_product_integrations ? length(local.default_product_arns) : 0
}

# -----------------------------------------------------------------------------
# Utility Outputs
# -----------------------------------------------------------------------------
output "securityhub_console_url" {
  description = "URL to view Security Hub in AWS Console"
  value       = "https://${local.region}.console.aws.amazon.com/securityhub/home?region=${local.region}#/summary"
}

output "control_finding_generator" {
  description = "Control finding generator type"
  value       = var.enable_security_hub ? var.control_finding_generator : null
}
