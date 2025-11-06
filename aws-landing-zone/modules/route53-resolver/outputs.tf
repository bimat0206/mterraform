output "outbound_resolver_security_group_id" {
  description = "ID of the security group created for Route 53 Resolver endpoints"
  value       = aws_security_group.resolver_outbound_endpoint.id
}
output "inbound_resolver_security_group_id" {
  description = "ID of the security group created for Route 53 Resolver endpoints"
  value       = aws_security_group.resolver_inbound_endpoint.id
}
output "inbound_resolver_endpoint_id" {
  description = "ID of the inbound resolver endpoint"
  value       = var.inbound_resolver_enabled ? aws_route53_resolver_endpoint.inbound[0].id : null
}

output "inbound_resolver_endpoint_ips" {
  description = "IP addresses of the inbound resolver endpoint"
  value       = var.inbound_resolver_enabled ? aws_route53_resolver_endpoint.inbound[0].ip_address[*].ip : []
}

output "outbound_resolver_endpoint_id" {
  description = "ID of the outbound resolver endpoint"
  value       = var.outbound_resolver_enabled ? aws_route53_resolver_endpoint.outbound[0].id : null
}

output "outbound_resolver_endpoint_ips" {
  description = "IP addresses of the outbound resolver endpoint"
  value       = var.outbound_resolver_enabled ? aws_route53_resolver_endpoint.outbound[0].ip_address[*].ip : []
}

output "resolver_rule_ids" {
  description = "IDs of the resolver rules created"
  value       = var.outbound_resolver_enabled ? aws_route53_resolver_rule.forward[*].id : []
}

output "resolver_rule_arns" {
  description = "ARNs of the resolver rules created"
  value       = var.outbound_resolver_enabled ? aws_route53_resolver_rule.forward[*].arn : []
}

output "query_log_config_id" {
  description = "ID of the Route53 Resolver query log configuration"
  value       = var.enable_query_logging ? aws_route53_resolver_query_log_config.this[0].id : null
}

output "query_log_config_arn" {
  description = "ARN of the Route53 Resolver query log configuration"
  value       = var.enable_query_logging ? aws_route53_resolver_query_log_config.this[0].arn : null
}
