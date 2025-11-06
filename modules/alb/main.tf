# -----------------------------------------------------------------------------
# Dynamic naming and tagging locals
# -----------------------------------------------------------------------------
locals {
  # Pick module default service if not provided
  _service = coalesce(var.service, "alb")

  # Join tokens, drop empties
  _tokens = compact([var.org_prefix, var.environment, var.workload, local._service, var.identifier])
  _raw    = join("-", local._tokens)

  # Normalize to AWS-friendly style: lowercase + hyphens only
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # S3 bucket name (must be globally unique and DNS-compliant)
  s3_bucket_name = var.create_s3_bucket ? "${local.name}-logs-${data.aws_caller_identity.current.account_id}" : var.s3_bucket_name

  # Security group IDs
  security_group_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids

  # Target groups map for easy lookup
  target_groups_map = {
    for tg in var.target_groups : tg.name => aws_lb_target_group.this[tg.name]
  }
}

# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "this" {}

# -----------------------------------------------------------------------------
# S3 Bucket for ALB Access Logs
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  count = var.create_s3_bucket && var.enable_access_logs ? 1 : 0

  bucket        = local.s3_bucket_name
  force_destroy = var.force_destroy_log_bucket

  tags = merge(var.tags, {
    Name    = "${local.name}-logs"
    Purpose = "ALB Access Logs"
  })
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count = var.create_s3_bucket && var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  count = var.create_s3_bucket && var.enable_access_logs && var.log_bucket_versioning ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = var.create_s3_bucket && var.enable_access_logs && var.log_bucket_encryption ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count = var.create_s3_bucket && var.enable_access_logs && var.log_bucket_lifecycle_enabled ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "log-retention"
    status = "Enabled"

    transition {
      days          = var.log_bucket_lifecycle_days
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.log_bucket_expiration_days
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  count = var.create_s3_bucket && var.enable_access_logs ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs[0].arn}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs[0].arn
      },
      # Legacy ALB service account access (for regions using legacy model)
      {
        Sid    = "AWSELBServiceAccountWrite"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.this.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs[0].arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.logs]
}

# -----------------------------------------------------------------------------
# Security Group for ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${local.name}-sg"
  description = "Security group for ${local.name} Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name}-sg"
  })
}

# Allow inbound HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  count = var.create_security_group && contains([for l in var.listeners : l.port], 80) ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "HTTP from allowed CIDR blocks"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "http_ipv6" {
  count = var.create_security_group && contains([for l in var.listeners : l.port], 80) && var.ip_address_type == "dualstack" ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "HTTP from allowed IPv6 CIDR blocks"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv6   = "::/0"
}

# Allow inbound HTTPS
resource "aws_vpc_security_group_ingress_rule" "https" {
  count = var.create_security_group && contains([for l in var.listeners : l.port], 443) ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "HTTPS from allowed CIDR blocks"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https_ipv6" {
  count = var.create_security_group && contains([for l in var.listeners : l.port], 443) && var.ip_address_type == "dualstack" ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "HTTPS from allowed IPv6 CIDR blocks"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv6   = "::/0"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "all" {
  count = var.create_security_group ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound traffic"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------
resource "aws_lb" "this" {
  name               = local.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = local.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  ip_address_type                  = var.ip_address_type
  idle_timeout                     = var.idle_timeout

  desync_mitigation_mode    = var.desync_mitigation_mode
  drop_invalid_header_fields = var.drop_invalid_header_fields

  # Access Logs
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = local.s3_bucket_name
      prefix  = var.s3_bucket_prefix
      enabled = true
    }
  }

  # Connection Logs (Beta)
  dynamic "connection_logs" {
    for_each = var.enable_connection_logs && var.enable_access_logs ? [1] : []
    content {
      bucket  = local.s3_bucket_name
      prefix  = var.s3_bucket_prefix != "" ? "${var.s3_bucket_prefix}/connection-logs" : "connection-logs"
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = local.name
  })

  depends_on = [
    aws_s3_bucket_policy.logs
  ]
}

# -----------------------------------------------------------------------------
# Target Groups
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  for_each = { for tg in var.target_groups : tg.name => tg }

  name        = "${local.name}-${each.value.name}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  deregistration_delay = each.value.deregistration_delay
  slow_start           = each.value.slow_start

  health_check {
    enabled             = each.value.health_check.enabled
    interval            = each.value.health_check.interval
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    matcher             = each.value.health_check.matcher
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness.enabled ? [1] : []
    content {
      type            = each.value.stickiness.type
      cookie_duration = each.value.stickiness.cookie_duration
      cookie_name     = each.value.stickiness.cookie_name
      enabled         = each.value.stickiness.enabled
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name}-${each.value.name}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Listeners
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "this" {
  for_each = { for idx, listener in var.listeners : "${listener.protocol}-${listener.port}" => listener }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = each.value.certificate_arn
  ssl_policy        = each.value.protocol == "HTTPS" ? each.value.ssl_policy : null

  default_action {
    type = each.value.default_action.type

    # Forward to target group
    dynamic "forward" {
      for_each = each.value.default_action.type == "forward" && each.value.default_action.target_group_key != null ? [1] : []
      content {
        target_group {
          arn = local.target_groups_map[each.value.default_action.target_group_key].arn
        }
      }
    }

    # Redirect
    dynamic "redirect" {
      for_each = each.value.default_action.type == "redirect" && each.value.default_action.redirect != null ? [1] : []
      content {
        protocol    = each.value.default_action.redirect.protocol
        port        = each.value.default_action.redirect.port
        status_code = each.value.default_action.redirect.status_code
      }
    }

    # Fixed response
    dynamic "fixed_response" {
      for_each = each.value.default_action.type == "fixed-response" && each.value.default_action.fixed_response != null ? [1] : []
      content {
        content_type = each.value.default_action.fixed_response.content_type
        message_body = each.value.default_action.fixed_response.message_body
        status_code  = each.value.default_action.fixed_response.status_code
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name}-${each.value.protocol}-${each.value.port}"
  })
}
