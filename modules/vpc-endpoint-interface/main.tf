# -----------------------------------------------------------------------------
# Dynamic naming and tagging locals
# -----------------------------------------------------------------------------
locals {
  # Pick module default service if not provided
  _service = coalesce(var.service, "vpce-if")

  # Join tokens, drop empties
  _tokens = compact([var.org_prefix, var.environment, var.workload, local._service, var.identifier])
  _raw    = join("-", local._tokens)

  # Normalize to AWS-friendly style: lowercase + hyphens only
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Filter enabled endpoints
  enabled_endpoints = {
    for k, v in var.endpoints : k => v if v == true
  }

  # Combine VPC CIDR with additional allowed CIDRs
  all_allowed_cidrs = distinct(concat([var.vpc_cidr_block], var.allowed_cidr_blocks))

  # Security group IDs to use
  security_group_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
}

# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Security Group for Interface Endpoints
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  count = var.create_security_group && length(local.enabled_endpoints) > 0 ? 1 : 0

  name        = "${local.name}-sg"
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  count = var.create_security_group && length(local.enabled_endpoints) > 0 ? length(local.all_allowed_cidrs) : 0

  security_group_id = aws_security_group.this[0].id
  description       = "HTTPS from ${local.all_allowed_cidrs[count.index]}"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = local.all_allowed_cidrs[count.index]
}

resource "aws_vpc_security_group_egress_rule" "all" {
  count = var.create_security_group && length(local.enabled_endpoints) > 0 ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound traffic"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# Interface VPC Endpoints
# -----------------------------------------------------------------------------
resource "aws_vpc_endpoint" "this" {
  for_each = local.enabled_endpoints

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = local.security_group_ids
  private_dns_enabled = var.private_dns_enabled

  tags = merge(var.tags, {
    Name = "${local.name}-${each.key}"
  })
}
