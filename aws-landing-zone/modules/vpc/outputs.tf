output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "vpc_name" {
  description = "The Name tag of the VPC."
  value       = local.vpc_name
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the general-purpose private subnets."
  value       = aws_subnet.private[*].id
}

# --- NEW ---
output "tgw_subnet_ids" {
  description = "List of IDs of the dedicated TGW attachment subnets."
  value       = aws_subnet.tgw[*].id
}

output "alb_subnet_ids" {
  description = "List of IDs of the dedicated ALB subnets."
  value       = aws_subnet.alb[*].id
}

output "alb_route_table_ids" {
  description = "List of IDs of the ALB subnet route tables."
  value       = aws_route_table.alb[*].id
}
# --- END NEW ---

output "public_route_table_ids" {
  description = "List of IDs of the public route tables (typically one)."
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the general-purpose private route tables (one per AZ or one shared)."
  value       = aws_route_table.private[*].id
}

# --- NEW ---
output "tgw_route_table_ids" {
  description = "List of IDs of the dedicated TGW subnet route tables (one per AZ or one shared)."
  value       = aws_route_table.tgw[*].id
}
# --- END NEW ---


output "nat_gateway_public_ips" {
  description = "List of public Elastic IP addresses assigned to the NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways."
  value       = aws_nat_gateway.this[*].id
}

output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = one(aws_internet_gateway.this[*].id) # Use one() as count is 0 or 1
}

output "vgw_id" {
  description = "The ID of the VPN Gateway (if created)."
  value       = one(aws_vpn_gateway.this[*].id) # Use one() as count is 0 or 1
}

# --- Flow Log Outputs ---
output "flow_log_id" {
  description = "The ID of the VPC Flow Log (if created)."
  value       = one(aws_flow_log.this[*].id)
}

output "flow_log_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs (if created)."
  value       = one(aws_cloudwatch_log_group.flow_log[*].arn)
}

output "flow_log_role_arn" {
  description = "The ARN of the IAM Role for VPC Flow Logs (if created)."
  value       = one(aws_iam_role.flow_log[*].arn)
}
