# -----------------------------------------------------------------------------
# Transit Gateway Outputs
# -----------------------------------------------------------------------------
output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_name" {
  description = "The name of the Transit Gateway"
  value       = local.name
}

output "transit_gateway_owner_id" {
  description = "The ID of the AWS account that owns the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.owner_id
}

output "transit_gateway_association_default_route_table_id" {
  description = "The ID of the default association route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "transit_gateway_propagation_default_route_table_id" {
  description = "The ID of the default propagation route table"
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}

# -----------------------------------------------------------------------------
# VPC Attachment Outputs
# -----------------------------------------------------------------------------
output "vpc_attachment_ids" {
  description = "Map of VPC attachment IDs"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.id }
}

output "vpc_attachment_vpc_ids" {
  description = "Map of VPC IDs for each attachment"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.vpc_id }
}

# -----------------------------------------------------------------------------
# Custom Route Table Outputs
# -----------------------------------------------------------------------------
output "custom_route_table_ids" {
  description = "Map of custom route table IDs"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "custom_route_table_arns" {
  description = "Map of custom route table ARNs"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.arn }
}

# -----------------------------------------------------------------------------
# Flow Logs Outputs
# -----------------------------------------------------------------------------
output "flow_logs_id" {
  description = "The ID of the Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.this[0].id : null
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for flow logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for flow logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_logs[0].arn : null
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role used for flow logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" && var.create_flow_logs_iam_role ? aws_iam_role.flow_logs[0].arn : null
}

# -----------------------------------------------------------------------------
# CloudWatch Alarm Outputs
# -----------------------------------------------------------------------------
output "cloudwatch_alarm_bytes_in_arn" {
  description = "The ARN of the BytesIn CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.bytes_in[0].arn : null
}

output "cloudwatch_alarm_bytes_out_arn" {
  description = "The ARN of the BytesOut CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.bytes_out[0].arn : null
}

output "cloudwatch_alarm_packet_drop_blackhole_arn" {
  description = "The ARN of the PacketDropBlackhole CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.packet_drop_blackhole[0].arn : null
}

output "cloudwatch_alarm_packet_drop_no_route_arn" {
  description = "The ARN of the PacketDropNoRoute CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.packet_drop_no_route[0].arn : null
}

# -----------------------------------------------------------------------------
# Resource Share Outputs
# -----------------------------------------------------------------------------
output "ram_resource_share_id" {
  description = "The ID of the RAM resource share"
  value       = var.enable_resource_sharing ? aws_ram_resource_share.this[0].id : null
}

output "ram_resource_share_arn" {
  description = "The ARN of the RAM resource share"
  value       = var.enable_resource_sharing ? aws_ram_resource_share.this[0].arn : null
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Insights Query Examples
# -----------------------------------------------------------------------------
output "cloudwatch_insights_query_top_talkers" {
  description = "CloudWatch Logs Insights query to find top talkers"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? "fields @timestamp, srcaddr, dstaddr, bytes | stats sum(bytes) as total_bytes by srcaddr, dstaddr | sort total_bytes desc | limit 20" : null
}

output "cloudwatch_insights_query_rejected_traffic" {
  description = "CloudWatch Logs Insights query to find rejected traffic"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? "fields @timestamp, srcaddr, dstaddr, srcport, dstport, protocol | filter `log-status` = 'NODATA' or `packets-lost-no-route` > 0 or `packets-lost-blackhole` > 0 | sort @timestamp desc | limit 100" : null
}

output "cloudwatch_insights_query_inter_vpc_traffic" {
  description = "CloudWatch Logs Insights query to analyze inter-VPC traffic"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? "fields @timestamp, `tgw-src-vpc-id`, `tgw-dst-vpc-id`, bytes, packets | filter `tgw-src-vpc-id` != `tgw-dst-vpc-id` | stats sum(bytes) as total_bytes, sum(packets) as total_packets by `tgw-src-vpc-id`, `tgw-dst-vpc-id` | sort total_bytes desc" : null
}

# -----------------------------------------------------------------------------
# Usage Commands
# -----------------------------------------------------------------------------
output "view_flow_logs_command" {
  description = "AWS CLI command to view flow logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? "aws logs tail ${local.flow_logs_log_group_name} --follow --format short" : null
}

output "describe_transit_gateway_command" {
  description = "AWS CLI command to describe the Transit Gateway"
  value       = "aws ec2 describe-transit-gateways --transit-gateway-ids ${aws_ec2_transit_gateway.this.id}"
}

output "describe_attachments_command" {
  description = "AWS CLI command to describe Transit Gateway attachments"
  value       = "aws ec2 describe-transit-gateway-attachments --filters Name=transit-gateway-id,Values=${aws_ec2_transit_gateway.this.id}"
}
