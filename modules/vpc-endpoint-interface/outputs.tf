# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------
output "security_group_id" {
  description = "The ID of the security group for VPC endpoints"
  value       = var.create_security_group && length(local.enabled_endpoints) > 0 ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group for VPC endpoints"
  value       = var.create_security_group && length(local.enabled_endpoints) > 0 ? aws_security_group.this[0].arn : null
}

output "security_group_name" {
  description = "The name of the security group for VPC endpoints"
  value       = var.create_security_group && length(local.enabled_endpoints) > 0 ? aws_security_group.this[0].name : null
}

# -----------------------------------------------------------------------------
# VPC Endpoint Outputs
# -----------------------------------------------------------------------------
output "endpoint_ids" {
  description = "Map of endpoint service names to endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "endpoint_arns" {
  description = "Map of endpoint service names to endpoint ARNs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.arn }
}

output "endpoint_dns_entries" {
  description = "Map of endpoint service names to DNS entries"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.dns_entry }
}

output "endpoint_network_interface_ids" {
  description = "Map of endpoint service names to network interface IDs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.network_interface_ids }
}

output "endpoint_states" {
  description = "Map of endpoint service names to endpoint states"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.state }
}

output "endpoint_count" {
  description = "Number of interface endpoints created"
  value       = length(aws_vpc_endpoint.this)
}

# -----------------------------------------------------------------------------
# Convenience Outputs
# -----------------------------------------------------------------------------
output "endpoints_created" {
  description = "List of endpoint service names that were created"
  value       = keys(aws_vpc_endpoint.this)
}
