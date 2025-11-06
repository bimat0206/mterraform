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
