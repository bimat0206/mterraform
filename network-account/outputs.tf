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
