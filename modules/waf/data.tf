# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# Locals for Naming Convention
# -----------------------------------------------------------------------------
locals {
  # Service name defaults to 'waf' if not provided
  _service = coalesce(var.service, "waf")

  # Build name from tokens
  _tokens = compact([
    var.org_prefix,
    var.environment,
    var.workload,
    local._service,
    var.identifier
  ])

  # Create normalized name
  _raw = join("-", local._tokens)
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Metric name prefix
  metric_prefix = var.metric_name_prefix != "" ? var.metric_name_prefix : local.name

  # CloudWatch log group name for WAF logs
  log_group_name = "/aws/wafv2/${local.name}"

  # Log destination ARN based on type
  log_destination_arn = (
    var.log_destination_type == "cloudwatch" ? aws_cloudwatch_log_group.waf[0].arn :
    var.log_destination_type == "s3" ? var.s3_bucket_arn :
    var.kinesis_firehose_arn
  )

  # Tags
  common_tags = merge(
    var.tags,
    {
      Name        = local.name
      Environment = var.environment
      Workload    = var.workload
      Service     = "WAF"
      ManagedBy   = "Terraform"
    }
  )

  # AWS Managed Rule Groups configuration
  managed_rule_groups = {
    core_rule_set = {
      enabled  = var.enable_core_rule_set
      name     = "AWSManagedRulesCommonRuleSet"
      priority = var.core_rule_set_priority
      vendor   = "AWS"
    }
    known_bad_inputs = {
      enabled  = var.enable_known_bad_inputs
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = var.known_bad_inputs_priority
      vendor   = "AWS"
    }
    sql_injection = {
      enabled  = var.enable_sql_injection
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = var.sql_injection_priority
      vendor   = "AWS"
    }
    linux_os = {
      enabled  = var.enable_linux_os
      name     = "AWSManagedRulesLinuxRuleSet"
      priority = var.linux_os_priority
      vendor   = "AWS"
    }
    unix_os = {
      enabled  = var.enable_unix_os
      name     = "AWSManagedRulesUnixRuleSet"
      priority = var.unix_os_priority
      vendor   = "AWS"
    }
    windows_os = {
      enabled  = var.enable_windows_os
      name     = "AWSManagedRulesWindowsRuleSet"
      priority = var.windows_os_priority
      vendor   = "AWS"
    }
    php_app = {
      enabled  = var.enable_php_app
      name     = "AWSManagedRulesPHPRuleSet"
      priority = var.php_app_priority
      vendor   = "AWS"
    }
    wordpress_app = {
      enabled  = var.enable_wordpress_app
      name     = "AWSManagedRulesWordPressRuleSet"
      priority = var.wordpress_app_priority
      vendor   = "AWS"
    }
    amazon_ip_reputation = {
      enabled  = var.enable_amazon_ip_reputation
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = var.amazon_ip_reputation_priority
      vendor   = "AWS"
    }
    anonymous_ip_list = {
      enabled  = var.enable_anonymous_ip_list
      name     = "AWSManagedRulesAnonymousIpList"
      priority = var.anonymous_ip_list_priority
      vendor   = "AWS"
    }
  }

  # Filter enabled managed rule groups
  enabled_managed_rule_groups = {
    for key, config in local.managed_rule_groups : key => config
    if config.enabled && var.enable_aws_managed_rules
  }
}
