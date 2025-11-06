# Enable RAM sharing with Organizations
#resource "aws_ram_sharing_with_organization" "this" {
#  count = var.share_with_organization ? 1 : 0
#}

# Use the common tag module
module "tags" {
  source = "../../../common-modules/tag"

  environment  = var.environment
  owner        = var.owner
  cost_center  = var.cost_center
  project_name = var.project_name
}

locals {
  # Determine which resource shares to create based on provided ARNs and names
  create_transit_gateway_share = contains(keys(var.resource_arns), "transit_gateway") && var.transit_gateway_share_name != ""
  create_route53_profile_share = contains(keys(var.resource_arns), "route53_profile") && var.route53_profile_share_name != ""
  create_query_logging_share   = length(var.query_logging_arns) > 0 && var.query_logging_share_name != ""

  # Default names if not provided
  transit_gateway_share_name = var.transit_gateway_share_name != "" ? var.transit_gateway_share_name : "${var.name_prefix}-tgw-share"
  route53_profile_share_name = var.route53_profile_share_name != "" ? var.route53_profile_share_name : "${var.name_prefix}-route53-profile-share"
  query_logging_share_name   = var.query_logging_share_name != "" ? var.query_logging_share_name : "${var.name_prefix}-query-logging-share"
}

# Transit Gateway Resource Share
resource "aws_ram_resource_share" "transit_gateway" {
  count = local.create_transit_gateway_share ? 1 : 0

  name                      = local.transit_gateway_share_name
  allow_external_principals = var.allow_external_principals || var.allow_sharing_with_anyone

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags,
      tags["CreationDate"]
    ]
  }

  tags = merge(
    module.tags.tags,
    {
      Name = local.transit_gateway_share_name
    }
  )
}

# Route53 Profile Resource Share
resource "aws_ram_resource_share" "route53_profile" {
  count = local.create_route53_profile_share ? 1 : 0

  name                      = local.route53_profile_share_name
  allow_external_principals = var.allow_external_principals || var.allow_sharing_with_anyone

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags,
      tags["CreationDate"]
    ]
  }

  tags = merge(
    module.tags.tags,
    {
      Name = local.route53_profile_share_name
    }
  )
}

# Query Logging Resource Share
resource "aws_ram_resource_share" "query_logging" {
  count = local.create_query_logging_share ? 1 : 0

  name                      = local.query_logging_share_name
  allow_external_principals = var.allow_external_principals || var.allow_sharing_with_anyone

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags,
      tags["CreationDate"]
    ]
  }

  tags = merge(
    module.tags.tags,
    {
      Name = local.query_logging_share_name
    }
  )
}

# Associate Transit Gateway with its share
resource "aws_ram_resource_association" "transit_gateway" {
  count = local.create_transit_gateway_share && contains(keys(var.resource_arns), "transit_gateway") ? 1 : 0

  resource_share_arn = aws_ram_resource_share.transit_gateway[0].arn
  resource_arn       = var.resource_arns["transit_gateway"]

  lifecycle {
    prevent_destroy = false
  }
}

# Associate Route53 Profile with its share
resource "aws_ram_resource_association" "route53_profile" {
  count = local.create_route53_profile_share && contains(keys(var.resource_arns), "route53_profile") ? 1 : 0

  resource_share_arn = aws_ram_resource_share.route53_profile[0].arn
  resource_arn       = var.resource_arns["route53_profile"]

  lifecycle {
    prevent_destroy = false
  }
}

# Associate Query Logging resources with their share
resource "aws_ram_resource_association" "query_logging" {
  for_each = local.create_query_logging_share ? toset(var.query_logging_arns) : []

  resource_share_arn = aws_ram_resource_share.query_logging[0].arn
  resource_arn       = each.value

  lifecycle {
    prevent_destroy = false
  }
}

# Share Transit Gateway with specific organizational units if configured
resource "aws_ram_principal_association" "transit_gateway_organizational_units" {
  for_each = local.create_transit_gateway_share ? toset(var.share_with_organizational_units) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.transit_gateway[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Route53 Profile with specific organizational units if configured
resource "aws_ram_principal_association" "route53_profile_organizational_units" {
  for_each = local.create_route53_profile_share ? toset(var.share_with_organizational_units) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.route53_profile[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Query Logging with specific organizational units if configured
resource "aws_ram_principal_association" "query_logging_organizational_units" {
  for_each = local.create_query_logging_share ? toset(var.share_with_organizational_units) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.query_logging[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Transit Gateway with specific accounts if configured
resource "aws_ram_principal_association" "transit_gateway_accounts" {
  for_each = local.create_transit_gateway_share ? toset(var.share_with_accounts) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.transit_gateway[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Route53 Profile with specific accounts if configured
resource "aws_ram_principal_association" "route53_profile_accounts" {
  for_each = local.create_route53_profile_share ? toset(var.share_with_accounts) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.route53_profile[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Query Logging with specific accounts if configured
resource "aws_ram_principal_association" "query_logging_accounts" {
  for_each = local.create_query_logging_share ? toset(var.share_with_accounts) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.query_logging[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Transit Gateway with specific organizations if configured
resource "aws_ram_principal_association" "transit_gateway_organizations" {
  for_each = local.create_transit_gateway_share ? toset(var.share_with_organizations) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.transit_gateway[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Route53 Profile with specific organizations if configured
resource "aws_ram_principal_association" "route53_profile_organizations" {
  for_each = local.create_route53_profile_share ? toset(var.share_with_organizations) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.route53_profile[0].arn

  lifecycle {
    prevent_destroy = false
  }
}

# Share Query Logging with specific organizations if configured
resource "aws_ram_principal_association" "query_logging_organizations" {
  for_each = local.create_query_logging_share ? toset(var.share_with_organizations) : []

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.query_logging[0].arn

  lifecycle {
    prevent_destroy = false
  }
}
