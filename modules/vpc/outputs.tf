# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the VPC"
  value       = var.enable_ipv6 ? aws_vpc.this.ipv6_cidr_block : null
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = aws_vpc_ipv4_cidr_block_association.secondary[*].cidr_block
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = local.name
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances launched into the VPC"
  value       = aws_vpc.this.instance_tenancy
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = aws_vpc.this.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = aws_vpc.this.enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = aws_vpc.this.main_route_table_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.this.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.this.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.this.default_route_table_id
}

# -----------------------------------------------------------------------------
# DHCP Options Outputs
# -----------------------------------------------------------------------------
output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value       = var.enable_dhcp_options ? aws_vpc_dhcp_options.this[0].id : null
}

# -----------------------------------------------------------------------------
# Internet Gateway Outputs
# -----------------------------------------------------------------------------
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.this.arn
}

# -----------------------------------------------------------------------------
# VPN Gateway Outputs
# -----------------------------------------------------------------------------
output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.this[0].id : null
}

output "vpn_gateway_arn" {
  description = "The ARN of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks of public subnets"
  value       = aws_subnet.public[*].ipv6_cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks of private subnets"
  value       = aws_subnet.private[*].ipv6_cidr_block
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnet_cidrs" {
  description = "List of CIDR blocks of database subnets"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnet_group_id" {
  description = "The ID of the database subnet group"
  value       = var.create_database_subnet_group && var.create_database_subnets ? aws_db_subnet_group.this[0].id : null
}

output "database_subnet_group_arn" {
  description = "The ARN of the database subnet group"
  value       = var.create_database_subnet_group && var.create_database_subnets ? aws_db_subnet_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# NAT Gateway Outputs
# -----------------------------------------------------------------------------
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

output "nat_gateway_allocation_ids" {
  description = "List of allocation IDs of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].id
}

# Backward compatibility
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway (first one if multiple)"
  value       = length(aws_nat_gateway.this) > 0 ? aws_nat_gateway.this[0].id : null
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway (first one if multiple)"
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].public_ip : null
}

# -----------------------------------------------------------------------------
# Route Table Outputs
# -----------------------------------------------------------------------------
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "public_route_table_arn" {
  description = "The ARN of the public route table"
  value       = aws_route_table.public.arn
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "private_route_table_arns" {
  description = "List of ARNs of private route tables"
  value       = aws_route_table.private[*].arn
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = aws_route_table.database[*].id
}

output "database_route_table_arns" {
  description = "List of ARNs of database route tables"
  value       = aws_route_table.database[*].arn
}

# Backward compatibility
output "private_route_table_id" {
  description = "The ID of the private route table (first one if multiple)"
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}

# -----------------------------------------------------------------------------
# VPC Flow Logs Outputs
# -----------------------------------------------------------------------------
output "vpc_flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.this[0].id : null
}

output "vpc_flow_log_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" && var.flow_logs_destination_arn == "" ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

output "vpc_flow_log_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" && var.flow_logs_destination_arn == "" ? aws_cloudwatch_log_group.flow_logs[0].arn : null
}

output "vpc_flow_log_iam_role_arn" {
  description = "The ARN of the IAM role used for VPC Flow Logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? aws_iam_role.flow_logs[0].arn : null
}

# -----------------------------------------------------------------------------
# VPC Endpoints Outputs
# -----------------------------------------------------------------------------
output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "vpc_endpoint_s3_prefix_list_id" {
  description = "The prefix list for the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].prefix_list_id : null
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "vpc_endpoint_dynamodb_prefix_list_id" {
  description = "The prefix list for the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].prefix_list_id : null
}

output "vpc_endpoint_interface_ids" {
  description = "Map of VPC interface endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "vpc_endpoint_interface_dns_entries" {
  description = "Map of VPC interface endpoint DNS entries"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.dns_entry }
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC endpoints"
  value       = length(local.interface_endpoints) > 0 ? aws_security_group.vpc_endpoints[0].id : null
}

# -----------------------------------------------------------------------------
# Network ACL Outputs
# -----------------------------------------------------------------------------
output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = var.manage_default_network_acl ? aws_default_network_acl.default[0].id : aws_vpc.this.default_network_acl_id
}

output "public_network_acl_id" {
  description = "The ID of the public network ACL"
  value       = var.public_dedicated_network_acl ? aws_network_acl.public[0].id : null
}

output "public_network_acl_arn" {
  description = "The ARN of the public network ACL"
  value       = var.public_dedicated_network_acl ? aws_network_acl.public[0].arn : null
}

output "private_network_acl_id" {
  description = "The ID of the private network ACL"
  value       = var.private_dedicated_network_acl ? aws_network_acl.private[0].id : null
}

output "private_network_acl_arn" {
  description = "The ARN of the private network ACL"
  value       = var.private_dedicated_network_acl ? aws_network_acl.private[0].arn : null
}

# -----------------------------------------------------------------------------
# Default Security Group Outputs
# -----------------------------------------------------------------------------
output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = var.manage_default_security_group ? aws_default_security_group.default[0].id : aws_vpc.this.default_security_group_id
}

# -----------------------------------------------------------------------------
# Availability Zones
# -----------------------------------------------------------------------------
output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}

output "az_count" {
  description = "Number of availability zones used"
  value       = var.az_count
}
