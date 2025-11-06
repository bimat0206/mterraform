# Use the common tag module
module "tags" {
  source = "../../../common-modules/tag"

  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center
  project_name = var.project_name
}

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                = var.amazon_side_asn
  auto_accept_shared_attachments = var.enable_auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association = var.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.enable_default_route_table_propagation ? "enable" : "disable"
  dns_support                    = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support              = var.enable_vpn_ecmp_support ? "enable" : "disable"
  
  tags = local.common_tags
  
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags["LastApplied"],
      tags["AutoTag_"],
      tags["aws:"],
      tags["CreationDate"]
    ]
  }
}

# Create VPC attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids
  
  dns_support                    = lookup(each.value, "dns_support", "enable")
  ipv6_support                   = lookup(each.value, "ipv6_support", "disable")
  appliance_mode_support         = lookup(each.value, "appliance_mode_support", "disable")
  transit_gateway_default_route_table_association = lookup(each.value, "default_route_table_association", var.enable_default_route_table_association)
  transit_gateway_default_route_table_propagation = lookup(each.value, "default_route_table_propagation", var.enable_default_route_table_propagation)
  
  tags = merge(
    module.tags.tags,
    {
      Name = each.value.name
    }
  )
  
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Create Transit Gateway Route Tables
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  
  tags = merge(
    module.tags.tags,
    {
      Name = each.value.name
    }
  )
  
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Associate attachments with route tables
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = {
    for pair in local.route_table_associations : "${pair.rt_key}.${pair.attachment_key}" => pair
  }

  transit_gateway_attachment_id  = local.attachment_ids[each.value.attachment_key]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.rt_key].id
}

# Configure route propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = {
    for pair in local.route_table_propagations : "${pair.rt_key}.${pair.attachment_key}" => pair
  }

  transit_gateway_attachment_id  = local.attachment_ids[each.value.attachment_key]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.rt_key].id
}

# Add static routes
resource "aws_ec2_transit_gateway_route" "this" {
  for_each = {
    for pair in local.static_routes : "${pair.rt_key}.${pair.cidr}" => pair
  }

  destination_cidr_block         = each.value.cidr
  transit_gateway_attachment_id  = local.attachment_ids[each.value.attachment_key]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.rt_key].id
}

# --- Flow Logs Configuration ---

# CloudWatch Log Group for Transit Gateway Flow Logs
resource "aws_cloudwatch_log_group" "tgw_flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name              = "/aws/transit-gateway/${var.name}/flow-logs"
  retention_in_days = var.flow_log_retention_in_days
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-tgw-flow-logs"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# IAM Role for Transit Gateway Flow Logs
resource "aws_iam_role" "tgw_flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "${var.name}-tgw-flow-log-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# IAM Policy for Transit Gateway Flow Logs
resource "aws_iam_role_policy" "tgw_flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name = "${var.name}-tgw-flow-log-policy"
  role = aws_iam_role.tgw_flow_log[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Flow Logs for Transit Gateway
resource "aws_flow_log" "transit_gateway" {
  count = var.enable_flow_logs ? 1 : 0
  
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  
  iam_role_arn    = aws_iam_role.tgw_flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.tgw_flow_log[0].arn
  
  log_destination_type  = "cloud-watch-logs"
  traffic_type          = "ALL"
  max_aggregation_interval = var.flow_log_max_aggregation_interval
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-flow-log"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Flow Logs for VPC Attachments
resource "aws_flow_log" "transit_gateway_vpc_attachment" {
  for_each = var.enable_flow_logs ? var.vpc_attachments : {}
  
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  
  iam_role_arn    = aws_iam_role.tgw_flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.tgw_flow_log[0].arn
  
  log_destination_type  = "cloud-watch-logs"
  traffic_type          = "ALL"
  max_aggregation_interval = var.flow_log_max_aggregation_interval
  
  # destination_options is only supported for S3 destination type, not for CloudWatch logs
  # Removed destination_options block to fix the error
  
  tags = merge(
    local.common_tags,
    {
      Name = "${each.value.name}-flow-log"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
  
  depends_on = [aws_cloudwatch_log_group.tgw_flow_log]
}