output "vpn_connection_id" {
  description = "The ID of the VPN connection."
  value       = aws_vpn_connection.this.id
}

output "vpn_connection_arn" {
  description = "The ARN of the VPN Connection."
  value       = aws_vpn_connection.this.arn
}

output "vpn_connection_name" {
  description = "The Name tag of the VPN Connection."
  value       = local.vpn_name
}

output "customer_gateway_id" {
  description = "The ID of the Customer Gateway."
  value       = aws_customer_gateway.this.id
}

output "customer_gateway_arn" {
  description = "The ARN of the Customer Gateway."
  value       = aws_customer_gateway.this.arn
}

output "tunnel1_address" {
  description = "The public IP address of Tunnel 1."
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel1_cgw_inside_address" {
  description = "The BGP Customer Gateway Inside IP address for Tunnel 1."
  value       = aws_vpn_connection.this.tunnel1_cgw_inside_address
  # Note: Only populated after the tunnel is up and BGP is established.
}

output "tunnel1_vgw_inside_address" {
  description = "The BGP AWS Virtual Private Gateway Inside IP address for Tunnel 1."
  value       = aws_vpn_connection.this.tunnel1_vgw_inside_address
  # Note: Only populated after the tunnel is up and BGP is established.
}

output "tunnel1_preshared_key" {
  description = "The pre-shared key for Tunnel 1. **Download configuration for full details**."
  value       = aws_vpn_connection.this.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel1_inside_cidr" {
  description = "The inside CIDR block for Tunnel 1."
  value       = aws_vpn_connection.this.tunnel1_inside_cidr
}

output "tunnel2_address" {
  description = "The public IP address of Tunnel 2."
  value       = aws_vpn_connection.this.tunnel2_address
}

output "tunnel2_cgw_inside_address" {
  description = "The BGP Customer Gateway Inside IP address for Tunnel 2."
  value       = aws_vpn_connection.this.tunnel2_cgw_inside_address
}

output "tunnel2_vgw_inside_address" {
  description = "The BGP AWS Virtual Private Gateway Inside IP address for Tunnel 2."
  value       = aws_vpn_connection.this.tunnel2_vgw_inside_address
}

output "tunnel2_preshared_key" {
  description = "The pre-shared key for Tunnel 2. **Download configuration for full details**."
  value       = aws_vpn_connection.this.tunnel2_preshared_key
  sensitive   = true
}

output "tunnel2_inside_cidr" {
  description = "The inside CIDR block for Tunnel 2."
  value       = aws_vpn_connection.this.tunnel2_inside_cidr
}

output "vpn_connection_transit_gateway_attachment_id" {
  description = "The ID of the Transit Gateway attachment for the VPN connection."
  value       = aws_vpn_connection.this.transit_gateway_attachment_id
}

output "tunnel1_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for VPN tunnel 1."
  value       = aws_cloudwatch_log_group.tunnel1.arn
}

output "tunnel2_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for VPN tunnel 2."
  value       = aws_cloudwatch_log_group.tunnel2.arn
}

output "vpn_cloudwatch_role_arn" {
  description = "The ARN of the IAM role for VPN CloudWatch logging."
  value       = aws_iam_role.vpn_cloudwatch.arn
}
