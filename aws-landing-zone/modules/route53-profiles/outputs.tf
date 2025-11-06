output "resolver_config_id" {
  description = "ID of the primary Route53 Resolver configuration"
  value       = var.enable ? aws_route53_resolver_config.primary[0].id : null
}

output "additional_resolver_config_ids" {
  description = "Map of VPC IDs to their Route53 Resolver configuration IDs"
  value       = var.enable ? {
    for vpc_id, config in aws_route53_resolver_config.additional : vpc_id => config.id
  } : {}
}

output "discovered_resolver_rules" {
  description = "List of resolver rule IDs used in the module"
  value       = var.enable ? local.resolver_rules : []
}

output "route53_profile_id" {
  description = "ID of the Route53 Profile created by the module"
  value       = var.enable ? aws_route53profiles_profile.main[0].id : null
}

output "route53_profile_arn" {
  description = "ARN of the Route53 Profile created by the module"
  value       = var.enable ? aws_route53profiles_profile.main[0].arn : null
}

output "zone_resource_associations" {
  description = "Map of hosted zone resource associations with the Route53 Profile"
  value       = var.enable ? {
    for k, v in aws_route53profiles_resource_association.private_zone_associations : k => v.id
  } : {}
}

output "rule_resource_associations" {
  description = "Map of resolver rule resource associations with the Route53 Profile"
  value       = var.enable ? {
    for k, v in aws_route53profiles_resource_association.resolver_rule_associations : k => v.id
  } : {}
}

output "vpc_profile_associations" {
  description = "Map of VPC associations with the Route53 Profile"
  value       = var.enable ? {
    for k, v in aws_route53profiles_association.vpc_profile_associations : k => v.id
  } : {}
}

output "query_log_config_id" {
  description = "ID of the Route53 Resolver query log configuration"
  value       = var.enable && var.enable_query_logging ? aws_route53_resolver_query_log_config.this[0].id : null
}

output "query_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for Route53 Resolver query logs"
  value       = var.enable && var.enable_query_logging ? aws_cloudwatch_log_group.resolver_query_logs[0].arn : null
}