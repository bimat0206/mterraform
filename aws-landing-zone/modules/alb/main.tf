# Use the common tag module
module "tags" {
  source = "../../../common-modules/tag"

  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center
  project_name = var.project_name
}

locals {
  # Create a consistent ALB name using prefix and name
  alb_name = "${var.name_prefix}-${var.name}-alb"

  # Security groups - either provided or created
  security_groups = var.create_security_group ? [aws_security_group.alb[0].id] : var.security_groups

  # Access logs configuration
  access_logs_enabled = var.access_logs_enabled
  access_logs_bucket  = length(var.access_logs_bucket) > 0 ? var.access_logs_bucket : (local.access_logs_enabled && length(aws_s3_bucket.access_logs) > 0 ? aws_s3_bucket.access_logs[0].id : "")

  # Connection logs configuration
  connection_logs_enabled = var.connection_logs_enabled
  connection_logs_bucket  = length(var.connection_logs_bucket) > 0 ? var.connection_logs_bucket : (local.connection_logs_enabled && length(aws_s3_bucket.connection_logs) > 0 ? aws_s3_bucket.connection_logs[0].id : "")

  # Tags with Name
  alb_tags = merge(module.tags.tags, var.tags, {
    Name = local.alb_name
  })

  # Process target groups for consistent naming
  target_groups_map = {
    for tg in var.target_groups : tg.name => tg
  }
}

# --- ALB Security Group ---
resource "aws_security_group" "alb" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name != null ? var.security_group_name : "${local.alb_name}-sg"
  description = "Security group for ${local.alb_name} ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.alb_tags, {
    Name = "${local.alb_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["CreationDate"]]
  }
}

# --- ALB Security Group Rules ---
resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.security_group_rules.ingress : idx => rule }

  security_group_id = aws_security_group.alb[0].id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)

  description = lookup(each.value, "description", "UAT ALB Security Group")

  depends_on = [aws_security_group.alb]
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.security_group_rules.egress : idx => rule }

  security_group_id = aws_security_group.alb[0].id
  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)

  description = lookup(each.value, "description", "Managed by Terraform")

  depends_on = [aws_security_group.alb]
}

# --- ALB Resource ---
resource "aws_lb" "main" {
  name               = local.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = local.security_groups
  subnets            = var.subnets

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  idle_timeout                     = var.idle_timeout
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  preserve_host_header             = var.preserve_host_header
  ip_address_type                  = var.ip_address_type

  access_logs {
    bucket  = aws_s3_bucket.access_logs[0].id
    enabled = true
    prefix  = "access-logs"
  }
  connection_logs {
    bucket  = aws_s3_bucket.connection_logs[0].id
    enabled = true
    prefix  = "connection-logs"
  }
  timeouts {
    create = var.load_balancer_create_timeout
    update = var.load_balancer_update_timeout
    delete = var.load_balancer_delete_timeout
  }

  tags = local.alb_tags

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }

  depends_on = [
    aws_s3_bucket_policy.access_logs
  ]
}

# --- Target Groups ---
resource "aws_lb_target_group" "main" {
  for_each = local.target_groups_map

  name        = each.key
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  dynamic "health_check" {
    for_each = [lookup(each.value, "health_check", {})]
    content {
      enabled             = lookup(health_check.value, "enabled", true)
      interval            = lookup(health_check.value, "interval", 30)
      path                = lookup(health_check.value, "path", "/")
      port                = lookup(health_check.value, "port", "traffic-port")
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", 3)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", 3)
      timeout             = lookup(health_check.value, "timeout", 5)
      protocol            = lookup(health_check.value, "protocol", "HTTP")
      matcher             = lookup(health_check.value, "matcher", "200")
    }
  }

  dynamic "stickiness" {
    for_each = [lookup(each.value, "stickiness", {})]
    content {
      enabled         = lookup(stickiness.value, "enabled", false)
      type            = lookup(stickiness.value, "type", "lb_cookie")
      cookie_duration = lookup(stickiness.value, "cookie_duration", 86400)
    }
  }

  tags = merge(local.alb_tags, {
    Name = each.key
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["CreationDate"]]
  }
}

# For the ALB module's main.tf, update the dynamic section for HTTPS Listeners and HTTP Listeners
# The issue is in the forward action block where "security_groups" is being used incorrectly

# HTTP Listeners, HTTPS Listeners, and HTTPS Listener Rules have been removed as requested
