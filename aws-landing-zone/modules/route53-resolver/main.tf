locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : "pb-network"
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Owner       = var.owner
    }
  )
}

# CloudWatch Log Group for Query Logging
resource "aws_cloudwatch_log_group" "resolver_query_logs" {
  count = var.enable_query_logging ? 1 : 0

  name              = "/aws/route53resolver/${local.name_prefix}/query-logs"
  retention_in_days = var.query_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-route53-query-logs"
    }
  )

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}

# Route53 Resolver Query Logging Config
resource "aws_route53_resolver_query_log_config" "this" {
  count = var.enable_query_logging ? 1 : 0

  name            = "${local.name_prefix}-route53-query-logging"
  destination_arn = aws_cloudwatch_log_group.resolver_query_logs[0].arn

  tags = {
    Name = "${local.name_prefix}-route53-query-logging"
  }

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}

# Associate VPC with Query Logging Config
resource "aws_route53_resolver_query_log_config_association" "primary_vpc" {
  count = var.enable_query_logging ? 1 : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.this[0].id
  resource_id                  = var.vpc_id
}

# Associate additional VPCs with Query Logging Config
resource "aws_route53_resolver_query_log_config_association" "additional_vpcs" {
  count = var.enable_query_logging ? length(var.additional_vpc_ids) : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.this[0].id
  resource_id                  = var.additional_vpc_ids[count.index]
}

# Security Group for Route 53 Resolver endpoints
resource "aws_security_group" "resolver_inbound_endpoint" {
  name        = "${local.name_prefix}-route53-resolver-inbound-endpoint-sg"
  description = "Security group for Route 53 Resolver inbound endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-route53-resolver-inbound-endpoint-sg"
    }
  )

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}

# Security Group for Route 53 Resolver endpoints
resource "aws_security_group" "resolver_outbound_endpoint" {
  name        = "${local.name_prefix}-route53-resolver-outbound-endpoint-sg"
  description = "Security group for Route 53 Resolver outbound endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-route53-resolver-outbound-endpoint-sg"
    }
  )

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}
# Inbound Resolver Endpoint
resource "aws_route53_resolver_endpoint" "inbound" {
  count = var.inbound_resolver_enabled ? 1 : 0

  name      = "${local.name_prefix}-route53-inbound-resolver"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.resolver_inbound_endpoint.id]

  dynamic "ip_address" {
    for_each = var.private_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = { for k, v in var.tags : k => v if v != "" && !startswith(lower(k), "aws:") }

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }

}

# Outbound Resolver Endpoint
resource "aws_route53_resolver_endpoint" "outbound" {
  count = var.outbound_resolver_enabled ? 1 : 0

  name      = "${local.name_prefix}-route53-outbound-resolver"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.resolver_outbound_endpoint.id]

  dynamic "ip_address" {
    for_each = var.private_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = { for k, v in var.tags : k => v if v != "" && !startswith(lower(k), "aws:") }
}

# Resolver Rules
resource "aws_route53_resolver_rule" "forward" {
  count = var.outbound_resolver_enabled ? length(var.resolver_rules_domain_names) : 0

  domain_name          = var.resolver_rules_domain_names[count.index]
  name                 = "${local.name_prefix}-route53-resolver-rule-${count.index}"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound[0].id

  dynamic "target_ip" {
    for_each = var.target_ips
    content {
      ip   = target_ip.value.ip
      port = target_ip.value.port
    }
  }

  tags = { for k, v in merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-route53-resolver-rule-${count.index}"
    }
  ) : k => v if v != "" && !startswith(lower(k), "aws:") }
}

# Associate Resolver Rules with VPCs
resource "aws_route53_resolver_rule_association" "primary_vpc" {
  count = var.outbound_resolver_enabled ? length(var.resolver_rules_domain_names) : 0

  resolver_rule_id = aws_route53_resolver_rule.forward[count.index].id
  vpc_id           = var.vpc_id
}

# Associate Resolver Rules with additional VPCs
resource "aws_route53_resolver_rule_association" "additional_vpcs" {
  count = var.outbound_resolver_enabled ? length(var.resolver_rules_domain_names) * length(var.additional_vpc_ids) : 0

  resolver_rule_id = aws_route53_resolver_rule.forward[floor(count.index / length(var.additional_vpc_ids))].id
  vpc_id           = var.additional_vpc_ids[count.index % length(var.additional_vpc_ids)]
}
