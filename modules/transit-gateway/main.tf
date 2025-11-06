# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Locals for Naming Convention
# -----------------------------------------------------------------------------
locals {
  # Service name defaults to 'tgw' if not provided
  _service = coalesce(var.service, "tgw")

  # Build name from tokens
  _tokens = compact([
    var.org_prefix,
    var.environment,
    var.workload,
    local._service,
    var.identifier
  ])

  # Create normalized name
  _raw = join("-", local._tokens)
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Description
  description = var.description != "" ? var.description : "Transit Gateway for ${var.environment} environment"

  # Flow Logs log group name
  flow_logs_log_group_name = "/aws/transitgateway/${local.name}"

  # Flow Logs IAM role name
  flow_logs_role_name = "${local.name}-flow-logs-role"

  # Tags
  common_tags = merge(
    var.tags,
    {
      Name        = local.name
      Environment = var.environment
      Workload    = var.workload
      Service     = "TransitGateway"
      ManagedBy   = "Terraform"
    }
  )
}

# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "this" {
  description                     = local.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  multicast_support               = var.multicast_support
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks

  tags = merge(
    local.common_tags,
    {
      Name = local.name
    }
  )
}

# -----------------------------------------------------------------------------
# VPC Attachments
# -----------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  dns_support                                     = each.value.dns_support
  ipv6_support                                    = each.value.ipv6_support
  appliance_mode_support                          = each.value.appliance_mode_support
  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-${each.key}"
    }
  )
}

# -----------------------------------------------------------------------------
# Custom Route Tables
# -----------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.create_custom_route_tables ? var.custom_route_tables : {}

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-${each.value.name}"
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for Flow Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = local.flow_logs_log_group_name
  retention_in_days = var.flow_logs_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = local.flow_logs_log_group_name
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Role for Flow Logs
# -----------------------------------------------------------------------------
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" && var.create_flow_logs_iam_role ? 1 : 0

  name = local.flow_logs_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = local.flow_logs_role_name
    }
  )
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" && var.create_flow_logs_iam_role ? 1 : 0

  name = "${local.flow_logs_role_name}-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.flow_logs[0].arn}:*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Transit Gateway Flow Logs
# -----------------------------------------------------------------------------
resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  traffic_type             = "ALL"
  transit_gateway_id       = aws_ec2_transit_gateway.this.id
  log_destination_type     = var.flow_logs_destination_type
  log_destination          = var.flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_logs[0].arn : var.flow_logs_s3_bucket_arn
  iam_role_arn             = var.flow_logs_destination_type == "cloud-watch-logs" ? (var.create_flow_logs_iam_role ? aws_iam_role.flow_logs[0].arn : var.flow_logs_iam_role_arn) : null
  log_format               = var.flow_logs_format
  max_aggregation_interval = var.flow_logs_max_aggregation_interval

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-flow-logs"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.flow_logs,
    aws_iam_role_policy.flow_logs
  ]
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "bytes_in" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-bytes-in-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesIn"
  namespace           = "AWS/TransitGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.bytes_in_threshold
  alarm_description   = "This metric monitors transit gateway bytes in"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TransitGateway = aws_ec2_transit_gateway.this.id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-bytes-in-high"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "bytes_out" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-bytes-out-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesOut"
  namespace           = "AWS/TransitGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.bytes_out_threshold
  alarm_description   = "This metric monitors transit gateway bytes out"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TransitGateway = aws_ec2_transit_gateway.this.id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-bytes-out-high"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "packet_drop_blackhole" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-packet-drop-blackhole"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PacketDropCountBlackhole"
  namespace           = "AWS/TransitGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.packet_drop_count_blackhole_threshold
  alarm_description   = "This metric monitors packet drops due to blackhole routes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TransitGateway = aws_ec2_transit_gateway.this.id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-packet-drop-blackhole"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "packet_drop_no_route" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-packet-drop-no-route"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PacketDropCountNoRoute"
  namespace           = "AWS/TransitGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.packet_drop_count_no_route_threshold
  alarm_description   = "This metric monitors packet drops due to no route"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TransitGateway = aws_ec2_transit_gateway.this.id
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-packet-drop-no-route"
    }
  )
}

# -----------------------------------------------------------------------------
# AWS RAM Resource Share
# -----------------------------------------------------------------------------
resource "aws_ram_resource_share" "this" {
  count = var.enable_resource_sharing ? 1 : 0

  name                      = "${local.name}-share"
  allow_external_principals = var.ram_allow_external_principals

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-share"
    }
  )
}

resource "aws_ram_resource_association" "this" {
  count = var.enable_resource_sharing ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "this" {
  for_each = var.enable_resource_sharing ? toset(var.ram_principals) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
