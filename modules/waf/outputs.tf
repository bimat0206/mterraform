# -----------------------------------------------------------------------------
# Web ACL Outputs
# -----------------------------------------------------------------------------
output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "The name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.name
}

output "web_acl_capacity" {
  description = "The capacity units used by the Web ACL"
  value       = aws_wafv2_web_acl.this.capacity
}

# -----------------------------------------------------------------------------
# IP Set Outputs
# -----------------------------------------------------------------------------
output "ip_allowlist_arn" {
  description = "ARN of the IP allowlist (if created)"
  value       = length(aws_wafv2_ip_set.allowlist) > 0 ? aws_wafv2_ip_set.allowlist[0].arn : null
}

output "ip_blocklist_arn" {
  description = "ARN of the IP blocklist (if created)"
  value       = length(aws_wafv2_ip_set.blocklist) > 0 ? aws_wafv2_ip_set.blocklist[0].arn : null
}

# -----------------------------------------------------------------------------
# Logging Outputs
# -----------------------------------------------------------------------------
output "log_group_name" {
  description = "CloudWatch Log Group name for WAF logs (if enabled)"
  value       = var.enable_logging && var.log_destination_type == "cloudwatch" ? aws_cloudwatch_log_group.waf[0].name : null
}

output "log_group_arn" {
  description = "CloudWatch Log Group ARN for WAF logs (if enabled)"
  value       = var.enable_logging && var.log_destination_type == "cloudwatch" ? aws_cloudwatch_log_group.waf[0].arn : null
}

# -----------------------------------------------------------------------------
# Association Outputs
# -----------------------------------------------------------------------------
output "associated_alb_count" {
  description = "Number of ALBs associated with this Web ACL"
  value       = length(var.associated_alb_arns)
}

output "associated_api_gateway_count" {
  description = "Number of API Gateway stages associated with this Web ACL"
  value       = length(var.associated_api_gateway_arns)
}

output "associated_appsync_count" {
  description = "Number of AppSync APIs associated with this Web ACL"
  value       = length(var.associated_appsync_arns)
}

# -----------------------------------------------------------------------------
# Configuration Summary
# -----------------------------------------------------------------------------
output "enabled_managed_rule_groups" {
  description = "List of enabled AWS Managed Rule Groups"
  value       = [for key, config in local.enabled_managed_rule_groups : config.name]
}

output "rate_limiting_enabled" {
  description = "Whether rate limiting is enabled"
  value       = var.enable_rate_limiting
}

output "rate_limit" {
  description = "Rate limit threshold (if enabled)"
  value       = var.enable_rate_limiting ? var.rate_limit : null
}

output "geo_blocking_enabled" {
  description = "Whether geographic blocking is enabled"
  value       = var.enable_geo_blocking
}

output "geo_blocked_countries" {
  description = "List of blocked country codes (if geo blocking is enabled)"
  value       = var.enable_geo_blocking ? var.geo_blocked_countries : []
}

output "default_action" {
  description = "Default action for the Web ACL"
  value       = var.default_action
}

output "scope" {
  description = "Scope of the Web ACL (REGIONAL or CLOUDFRONT)"
  value       = var.scope
}

# -----------------------------------------------------------------------------
# Management Commands
# -----------------------------------------------------------------------------
output "view_logs_command" {
  description = "Command to view WAF logs in CloudWatch"
  value       = var.enable_logging && var.log_destination_type == "cloudwatch" ? "aws logs tail ${local.log_group_name} --follow --format short" : "Logging not enabled or not using CloudWatch"
}

output "get_sampled_requests_command" {
  description = "Command to get sampled requests for this Web ACL"
  value       = "aws wafv2 get-sampled-requests --web-acl-arn ${aws_wafv2_web_acl.this.arn} --rule-metric-name ${local.metric_prefix}-web-acl --scope ${var.scope} --time-window StartTime=$(date -u -d '1 hour ago' +%s),EndTime=$(date -u +%s) --max-items 100"
}

output "list_resources_command" {
  description = "Command to list resources associated with this Web ACL"
  value       = "aws wafv2 list-resources-for-web-acl --web-acl-arn ${aws_wafv2_web_acl.this.arn} --resource-type ${var.scope == "REGIONAL" ? "APPLICATION_LOAD_BALANCER" : "CLOUDFRONT"}"
}

output "get_web_acl_command" {
  description = "Command to describe this Web ACL"
  value       = "aws wafv2 get-web-acl --id ${aws_wafv2_web_acl.this.id} --name ${aws_wafv2_web_acl.this.name} --scope ${var.scope}"
}

# -----------------------------------------------------------------------------
# CloudWatch Metrics
# -----------------------------------------------------------------------------
output "cloudwatch_metrics_namespace" {
  description = "CloudWatch metrics namespace for this Web ACL"
  value       = "AWS/WAFV2"
}

output "cloudwatch_metric_names" {
  description = "CloudWatch metric names for this Web ACL"
  value = concat(
    ["${local.metric_prefix}-web-acl"],
    [for key, config in local.enabled_managed_rule_groups : "${local.metric_prefix}-${key}"],
    var.enable_rate_limiting ? ["${local.metric_prefix}-rate-limit"] : [],
    var.enable_geo_blocking ? ["${local.metric_prefix}-geo-blocking"] : [],
    length(var.ip_allowlist) > 0 ? ["${local.metric_prefix}-ip-allowlist"] : [],
    length(var.ip_blocklist) > 0 ? ["${local.metric_prefix}-ip-blocklist"] : []
  )
}
