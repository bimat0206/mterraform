output "transit_gateway_id" {
  description = "EC2 Transit Gateway identifier"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "EC2 Transit Gateway Amazon Resource Name (ARN)"
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_owner_id" {
  description = "Identifier of the AWS account that owns the EC2 Transit Gateway"
  value       = aws_ec2_transit_gateway.this.owner_id
}

output "vpc_attachments" {
  description = "Map of VPC attachments"
  value = {
    for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => {
      id         = v.id
      vpc_id     = v.vpc_id
      subnet_ids = v.subnet_ids
    }
  }
}

output "route_tables" {
  description = "Map of route tables with their details"
  value = {
    for k, v in aws_ec2_transit_gateway_route_table.this : k => {
      id   = v.id
      arn  = v.arn
      name = var.route_tables[k].name
    }
  }
}

output "route_table_associations" {
  description = "Map of route table associations with their details"
  value = {
    for k, v in aws_ec2_transit_gateway_route_table_association.this : k => {
      id                           = v.id
      resource_id                  = v.resource_id
      resource_type               = v.resource_type
      transit_gateway_route_table_id = v.transit_gateway_route_table_id
    }
  }
}

output "route_table_propagations" {
  description = "Map of route table propagations with their details"
  value = {
    for k, v in aws_ec2_transit_gateway_route_table_propagation.this : k => {
      id                           = v.id
      resource_id                  = v.resource_id
      resource_type               = v.resource_type
      transit_gateway_route_table_id = v.transit_gateway_route_table_id
    }
  }
}

output "tgw_flow_log_role_arn" {
  description = "ARN of the IAM role used for flow logs"
  value       = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? aws_iam_role.tgw_flow_log[0].arn : ""
}

output "tgw_flow_log_group_arn" {
  description = "ARN of the CloudWatch log group for flow logs"
  value       = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.tgw_flow_log[0].arn : ""
}

output "tgw_flow_log_id" {
  description = "ID of the Transit Gateway flow log"
  value       = var.enable_flow_logs ? aws_flow_log.transit_gateway[0].id : ""
}

output "vpc_attachment_flow_logs" {
  description = "Map of VPC attachment flow logs"
  value = var.enable_flow_logs ? {
    for k, v in aws_flow_log.transit_gateway_vpc_attachment : k => {
      id               = v.id
      attachment_id    = v.transit_gateway_attachment_id
      log_destination  = v.log_destination
    }
  } : {}
}

output "flow_logs_enabled" {
  description = "Whether flow logs are enabled"
  value       = var.enable_flow_logs
}

output "flow_log_destination_type" {
  description = "Destination type for flow logs"
  value       = var.flow_log_destination_type
}