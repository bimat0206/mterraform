# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.vpc.vpc_name
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway (if enabled)"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway (if enabled)"
  value       = module.vpc.nat_gateway_public_ip
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.availability_zones
}

# -----------------------------------------------------------------------------
# VPC Gateway Endpoints Outputs
# -----------------------------------------------------------------------------
output "s3_endpoint_id" {
  description = "The ID of the S3 VPC endpoint (if enabled)"
  value       = var.vpce_gateway_enabled ? module.vpc_gateway_endpoints[0].s3_endpoint_id : null
}

output "dynamodb_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint (if enabled)"
  value       = var.vpce_gateway_enabled ? module.vpc_gateway_endpoints[0].dynamodb_endpoint_id : null
}

# -----------------------------------------------------------------------------
# VPC Interface Endpoints Outputs
# -----------------------------------------------------------------------------
output "interface_endpoint_ids" {
  description = "Map of interface endpoint service names to IDs (if enabled)"
  value       = var.vpce_interface_enabled && length(var.vpce_interface_endpoints) > 0 ? module.vpc_interface_endpoints[0].endpoint_ids : {}
}

output "interface_endpoint_security_group_id" {
  description = "The ID of the security group for interface endpoints (if enabled)"
  value       = var.vpce_interface_enabled && length(var.vpce_interface_endpoints) > 0 ? module.vpc_interface_endpoints[0].security_group_id : null
}

output "endpoints_created" {
  description = "List of interface endpoint service names that were created"
  value       = var.vpce_interface_enabled && length(var.vpce_interface_endpoints) > 0 ? module.vpc_interface_endpoints[0].endpoints_created : []
}

# -----------------------------------------------------------------------------
# ACM Outputs
# -----------------------------------------------------------------------------
output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate (if enabled)"
  value       = var.acm_enabled ? module.acm[0].certificate_arn : null
}

output "acm_certificate_domain_name" {
  description = "The domain name of the ACM certificate (if enabled)"
  value       = var.acm_enabled ? module.acm[0].certificate_domain_name : null
}

output "acm_certificate_status" {
  description = "The status of the ACM certificate (if enabled)"
  value       = var.acm_enabled ? module.acm[0].certificate_status : null
}

# -----------------------------------------------------------------------------
# ALB Outputs
# -----------------------------------------------------------------------------
output "alb_id" {
  description = "The ID of the ALB (if enabled)"
  value       = var.alb_enabled ? module.alb[0].alb_id : null
}

output "alb_arn" {
  description = "The ARN of the ALB (if enabled)"
  value       = var.alb_enabled ? module.alb[0].alb_arn : null
}

output "alb_dns_name" {
  description = "The DNS name of the ALB (if enabled)"
  value       = var.alb_enabled ? module.alb[0].alb_dns_name : null
}

output "alb_zone_id" {
  description = "The zone ID of the ALB (if enabled)"
  value       = var.alb_enabled ? module.alb[0].alb_zone_id : null
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group (if enabled)"
  value       = var.alb_enabled ? module.alb[0].security_group_id : null
}

output "alb_target_group_arns" {
  description = "Map of target group names to ARNs (if enabled)"
  value       = var.alb_enabled ? module.alb[0].target_group_arns : {}
}

output "alb_listener_arns" {
  description = "Map of listener keys to ARNs (if enabled)"
  value       = var.alb_enabled ? module.alb[0].listener_arns : {}
}

output "alb_endpoint" {
  description = "The HTTP endpoint of the ALB (if enabled)"
  value       = var.alb_enabled ? module.alb[0].endpoint : null
}

output "alb_https_endpoint" {
  description = "The HTTPS endpoint of the ALB (if enabled)"
  value       = var.alb_enabled ? module.alb[0].https_endpoint : null
}

output "alb_s3_bucket_id" {
  description = "The ID of the S3 bucket for ALB logs (if enabled)"
  value       = var.alb_enabled ? module.alb[0].s3_bucket_id : null
}

output "alb_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB logs (if enabled)"
  value       = var.alb_enabled ? module.alb[0].s3_bucket_arn : null
}

# -----------------------------------------------------------------------------
# Transit Gateway Outputs
# -----------------------------------------------------------------------------
output "transit_gateway_id" {
  description = "The ID of the Transit Gateway (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].transit_gateway_id : null
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].transit_gateway_arn : null
}

output "transit_gateway_name" {
  description = "The name of the Transit Gateway (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].transit_gateway_name : null
}

output "transit_gateway_association_default_route_table_id" {
  description = "The ID of the default association route table (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].transit_gateway_association_default_route_table_id : null
}

output "transit_gateway_propagation_default_route_table_id" {
  description = "The ID of the default propagation route table (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].transit_gateway_propagation_default_route_table_id : null
}

output "transit_gateway_vpc_attachment_ids" {
  description = "Map of VPC attachment IDs (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].vpc_attachment_ids : {}
}

output "transit_gateway_flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for Transit Gateway flow logs (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].flow_logs_log_group_name : null
}

output "transit_gateway_flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for Transit Gateway flow logs (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].flow_logs_log_group_arn : null
}

output "transit_gateway_view_flow_logs_command" {
  description = "AWS CLI command to view Transit Gateway flow logs (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].view_flow_logs_command : null
}

output "transit_gateway_describe_command" {
  description = "AWS CLI command to describe the Transit Gateway (if enabled)"
  value       = var.tgw_enabled ? module.transit_gateway[0].describe_transit_gateway_command : null
}

# -----------------------------------------------------------------------------
# WAF Outputs
# -----------------------------------------------------------------------------
output "waf_web_acl_id" {
  description = "WAF Web ACL ID (if enabled)"
  value       = var.waf_enabled ? module.waf[0].web_acl_id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN (if enabled)"
  value       = var.waf_enabled ? module.waf[0].web_acl_arn : null
}

output "waf_web_acl_name" {
  description = "WAF Web ACL name (if enabled)"
  value       = var.waf_enabled ? module.waf[0].web_acl_name : null
}

output "waf_web_acl_capacity" {
  description = "WAF Web ACL capacity units (if enabled)"
  value       = var.waf_enabled ? module.waf[0].web_acl_capacity : null
}

output "waf_log_group_name" {
  description = "CloudWatch log group name for WAF logs (if enabled)"
  value       = var.waf_enabled ? module.waf[0].log_group_name : null
}

output "waf_log_group_arn" {
  description = "CloudWatch log group ARN for WAF logs (if enabled)"
  value       = var.waf_enabled ? module.waf[0].log_group_arn : null
}

output "waf_enabled_managed_rule_groups" {
  description = "List of enabled AWS Managed Rule Groups (if enabled)"
  value       = var.waf_enabled ? module.waf[0].enabled_managed_rule_groups : null
}

output "waf_rate_limiting_enabled" {
  description = "Whether rate limiting is enabled (if enabled)"
  value       = var.waf_enabled ? module.waf[0].rate_limiting_enabled : null
}

output "waf_rate_limit" {
  description = "Rate limit threshold (if enabled)"
  value       = var.waf_enabled ? module.waf[0].rate_limit : null
}

output "waf_geo_blocking_enabled" {
  description = "Whether geographic blocking is enabled (if enabled)"
  value       = var.waf_enabled ? module.waf[0].geo_blocking_enabled : null
}

output "waf_geo_blocked_countries" {
  description = "List of blocked country codes (if enabled)"
  value       = var.waf_enabled ? module.waf[0].geo_blocked_countries : null
}

output "waf_default_action" {
  description = "Default action for the Web ACL (if enabled)"
  value       = var.waf_enabled ? module.waf[0].default_action : null
}

output "waf_scope" {
  description = "Scope of the Web ACL (if enabled)"
  value       = var.waf_enabled ? module.waf[0].scope : null
}

output "waf_associated_alb_count" {
  description = "Number of ALBs associated with WAF (if enabled)"
  value       = var.waf_enabled ? module.waf[0].associated_alb_count : null
}

output "waf_associated_api_gateway_count" {
  description = "Number of API Gateway stages associated with WAF (if enabled)"
  value       = var.waf_enabled ? module.waf[0].associated_api_gateway_count : null
}

output "waf_view_logs_command" {
  description = "Command to view WAF logs (if enabled)"
  value       = var.waf_enabled ? module.waf[0].view_logs_command : null
}

output "waf_get_sampled_requests_command" {
  description = "Command to get sampled requests (if enabled)"
  value       = var.waf_enabled ? module.waf[0].get_sampled_requests_command : null
}

output "waf_list_resources_command" {
  description = "Command to list associated resources (if enabled)"
  value       = var.waf_enabled ? module.waf[0].list_resources_command : null
}

output "waf_cloudwatch_metric_names" {
  description = "CloudWatch metric names for WAF (if enabled)"
  value       = var.waf_enabled ? module.waf[0].cloudwatch_metric_names : null
}
