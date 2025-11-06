# -----------------------------------------------------------------------------
# WAF Web ACL
# -----------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "this" {
  name        = local.name
  description = var.description != "" ? var.description : "Web ACL for ${local.name}"
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # IP Allowlist Rule (highest priority)
  dynamic "rule" {
    for_each = length(var.ip_allowlist) > 0 ? [1] : []
    content {
      name     = "${local.name}-ip-allowlist"
      priority = var.ip_allowlist_priority

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowlist[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.metric_prefix}-ip-allowlist"
        sampled_requests_enabled   = true
      }
    }
  }

  # IP Blocklist Rule
  dynamic "rule" {
    for_each = length(var.ip_blocklist) > 0 ? [1] : []
    content {
      name     = "${local.name}-ip-blocklist"
      priority = var.ip_blocklist_priority

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocklist[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.metric_prefix}-ip-blocklist"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate Limiting Rule
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "${local.name}-rate-limit"
      priority = var.rate_limit_priority

      dynamic "action" {
        for_each = var.rate_limit_action == "block" ? [1] : []
        content {
          block {}
        }
      }

      dynamic "action" {
        for_each = var.rate_limit_action == "count" ? [1] : []
        content {
          count {}
        }
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.metric_prefix}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  }

  # Geographic Blocking Rule
  dynamic "rule" {
    for_each = var.enable_geo_blocking && length(var.geo_blocked_countries) > 0 ? [1] : []
    content {
      name     = "${local.name}-geo-blocking"
      priority = var.geo_blocking_priority

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.geo_blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.metric_prefix}-geo-blocking"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed Rule Groups
  dynamic "rule" {
    for_each = local.enabled_managed_rule_groups
    content {
      name     = "${local.name}-${rule.key}"
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          vendor_name = rule.value.vendor
          name        = rule.value.name

          # Bot Control specific configuration
          dynamic "managed_rule_group_configs" {
            for_each = rule.key == "bot_control" && var.enable_bot_control ? [1] : []
            content {
              aws_managed_rules_bot_control_rule_set {
                inspection_level = var.bot_control_inspection_level
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.metric_prefix}-${rule.key}"
        sampled_requests_enabled   = true
      }
    }
  }

  # Bot Control Rule (separate due to special configuration)
  dynamic "rule" {
    for_each = var.enable_bot_control && var.enable_aws_managed_rules ? [1] : []
    content {
      name     = "${local.name}-bot-control"
      priority = var.bot_control_priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = "AWSManagedRulesBotControlRuleSet"

          managed_rule_group_configs {
            aws_managed_rules_bot_control_rule_set {
              inspection_level = var.bot_control_inspection_level
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.metric_prefix}-bot-control"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
    metric_name                = "${local.metric_prefix}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = local.common_tags
}
