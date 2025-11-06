locals {
  # Create a consistent naming prefix
  name_prefix = var.name_prefix != "" ? "${var.name_prefix}-${var.shared_vpc_name}" : var.shared_vpc_name

  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Name = local.name_prefix
    }
  )

  # Ensure we have a list of unique VPC IDs including the shared VPC
  all_vpcs = distinct(concat([var.shared_vpc_id], var.consumer_vpc_ids))
  
  # Create a map of VPC IDs to associate with the hosted zones
  vpc_associations = {
    for vpc_id in local.all_vpcs : vpc_id => vpc_id if vpc_id != ""
  }

  # Get the primary VPC ID for hosted zones - this is used for initial zone creation
  primary_vpc_id = var.shared_vpc_id
}

# Create EC2 service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "ec2_zone" {
  count = var.ec2_endpoint_id != "" ? 1 : 0
  name  = "ec2.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.name_prefix}-ec2-phz"
      Comment = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "ec2_alias" {
  count   = var.ec2_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.ec2_zone[0].id
  name    = "ec2.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ec2_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.ec2_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Create EC2 Messages service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "ec2messages_zone" {
  count = 1
  name  = "ec2messages.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-ec2messages-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "ec2messages_alias" {
  count   = var.ec2messages_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.ec2messages_zone[0].id
  name    = "ec2messages.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ec2messages_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.ec2messages_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Create CloudWatch Logs service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "logs_zone" {
  count = var.logs_endpoint_id != "" ? 1 : 0
  name  = "logs.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-logs-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "logs_alias" {
  count   = var.logs_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.logs_zone[0].id
  name    = "logs.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.logs_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.logs_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Create SSM service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "ssm_zone" {
  count = var.ssm_endpoint_id != "" ? 1 : 0
  name  = "ssm.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-ssm-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "ssm_alias" {
  count   = var.ssm_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.ssm_zone[0].id
  name    = "ssm.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ssm_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.ssm_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Create Elastic Load Balancing service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "elasticloadbalancing_zone" {
  count = var.elasticloadbalancing_endpoint_id != "" ? 1 : 0
  name  = "elasticloadbalancing.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-elasticloadbalancing-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "elasticloadbalancing_alias" {
  count   = var.elasticloadbalancing_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.elasticloadbalancing_zone[0].id
  name    = "elasticloadbalancing.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.elasticloadbalancing_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.elasticloadbalancing_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Create SSM Messages service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "ssmmessages_zone" {
  count = var.ssmmessages_endpoint_id != "" ? 1 : 0
  name  = "ssmmessages.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-ssmmessages-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "ssmmessages_alias" {
  count   = var.ssmmessages_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.ssmmessages_zone[0].id
  name    = "ssmmessages.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ssmmessages_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.ssmmessages_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Create S3 service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "s3_zone" {
  count = var.create_s3_endpoint_zone ? 1 : 0
  name  = "s3.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-s3-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "s3_alias" {
  count   = var.create_s3_endpoint_zone ? 1 : 0
  zone_id = aws_route53_zone.s3_zone[0].id
  name    = "s3.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.s3_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.s3_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Associate EC2 private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "ec2_zone_association" {
  for_each = var.ec2_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.ec2_zone[0].id
  vpc_id  = each.value
}

# Associate EC2 Messages private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "ec2messages_zone_association" {
  for_each = var.ec2messages_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.ec2messages_zone[0].id
  vpc_id  = each.value
}

# Associate CloudWatch Logs private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "logs_zone_association" {
  for_each = var.logs_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.logs_zone[0].id
  vpc_id  = each.value
}

# Associate SSM private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "ssm_zone_association" {
  for_each = var.ssm_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.ssm_zone[0].id
  vpc_id  = each.value
}

# Associate Elastic Load Balancing private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "elasticloadbalancing_zone_association" {
  for_each = var.elasticloadbalancing_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.elasticloadbalancing_zone[0].id
  vpc_id  = each.value
}

# Associate SSM Messages private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "ssmmessages_zone_association" {
  for_each = var.ssmmessages_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.ssmmessages_zone[0].id
  vpc_id  = each.value
}

# Associate S3 private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "s3_zone_association" {
  for_each = var.create_s3_endpoint_zone ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.s3_zone[0].id
  vpc_id  = each.value
}

# Create GuardDuty service private hosted zone with interface endpoint alias
resource "aws_route53_zone" "guardduty_zone" {
  count = var.guardduty_endpoint_id != "" ? 1 : 0
  name  = "guardduty-data.${var.region}.amazonaws.com"
  vpc {
    vpc_id = local.primary_vpc_id
  }
  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-guardduty-phz"
      Description = "Centralize access using VPC interface endpoints"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["CreationDate"],
      vpc
    ]
  }
}

resource "aws_route53_record" "guardduty_alias" {
  count   = var.guardduty_endpoint_id != "" ? 1 : 0
  zone_id = aws_route53_zone.guardduty_zone[0].id
  name    = "guardduty-data.${var.region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.guardduty_endpoint_dns_entry[0]["dns_name"]
    zone_id                = var.guardduty_endpoint_dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = true
  }
}

# Associate GuardDuty private hosted zone with consumer VPCs
resource "aws_route53_zone_association" "guardduty_zone_association" {
  for_each = var.guardduty_endpoint_id != "" ? {
    for k, v in local.vpc_associations : k => v if k != local.primary_vpc_id || !var.skip_existing_associations
  } : {}

  zone_id = aws_route53_zone.guardduty_zone[0].id
  vpc_id  = each.value

  lifecycle {
    ignore_changes = [vpc_id]
  }
}

# No need to create A records as AWS already manages these in the private hosted zones

# No need to create wildcard records as AWS already manages these in the private hosted zones
