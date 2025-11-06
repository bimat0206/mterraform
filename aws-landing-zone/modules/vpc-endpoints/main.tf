locals {
  # Create a consistent naming prefix
  name_prefix = var.name_prefix != "" ? "${var.name_prefix}-${var.vpc_name}" : var.vpc_name
  
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Name = local.name_prefix
    }
  )
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name_prefix}-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
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
      Name = "${local.name_prefix}-endpoints-sg"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Interface VPC Endpoints
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ec2-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ec2messages-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-logs-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ssm-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_vpc_endpoint" "elasticloadbalancing" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-elb-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ssmmessages-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Interface VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-s3-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

# Interface VPC Endpoint for GuardDuty
resource "aws_vpc_endpoint" "guardduty" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.guardduty-data"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-guardduty-endpoint"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}
