# Route53 Profiles Module (Simplified with Manual Configuration)

locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : "pb"
  region      = var.region != "" ? var.region : "ap-southeast-1"
  account_id  = var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id

  # Ensure no duplicate VPC IDs
  unique_vpc_ids = distinct(concat([var.primary_vpc_id], var.additional_vpc_ids))

  # Use provided hosted zones and resolver rules instead of auto-discovery
  # This avoids the unpredictable behavior with data sources
  # Format hosted zone IDs as ARNs if they're not already
  private_hosted_zones = [
    for zone_id in var.private_hosted_zones :
    startswith(zone_id, "arn:") ? zone_id : "arn:aws:route53:::hostedzone/${zone_id}"
  ]

  # Format resolver rule IDs as ARNs if they're not already
  resolver_rules = [
    for rule_id in var.resolver_rules :
    startswith(rule_id, "arn:") ? rule_id : "arn:aws:route53resolver:${local.region}:${local.account_id}:resolver-rule/${rule_id}"
  ]

  # Generate combinations for hosted zone and profile resource associations with static keys
  # Using the zone ID itself as part of the key to ensure stability during planning
  hosted_zone_profile_combinations = var.enable ? {
    for zone_arn in local.private_hosted_zones :
    replace(zone_arn, "arn:aws:route53:::hostedzone/", "") => {
      zone_id = zone_arn
      name    = "${local.name_prefix}-zone-${replace(zone_arn, "arn:aws:route53:::hostedzone/", "")}"
    }
  } : {}

  # Generate combinations for resolver rule and profile resource associations with static keys
  # Using the rule ID itself as part of the key to ensure stability during planning
  resolver_rule_profile_combinations = var.enable ? {
    for rule_arn in local.resolver_rules :
    replace(rule_arn, "arn:aws:route53resolver:${local.region}:${local.account_id}:resolver-rule/", "") => {
      resolver_rule_id = rule_arn
      name             = "${local.name_prefix}-rule-${replace(rule_arn, "arn:aws:route53resolver:${local.region}:${local.account_id}:resolver-rule/", "")}"
    }
  } : {}

  # Generate VPC profile associations - using VPC ID as the key to ensure stability
  vpc_profile_combinations = var.enable ? {
    for vpc_id in local.unique_vpc_ids : vpc_id => {
      vpc_id = vpc_id
      name   = "${local.name_prefix}-vpc-${vpc_id}"
    }
  } : {}

  # Filter out combinations to skip - using the zone ID itself for filtering
  filtered_hosted_zone_profile_combinations = {
    for k, v in local.hosted_zone_profile_combinations : k => v
    if !contains(var.skip_zone_associations, k)
  }

  # Use the rule ID itself for filtering, ensuring keys are known at plan time
  filtered_resolver_rule_profile_combinations = {
    for k, v in local.resolver_rule_profile_combinations : k => v
    if !contains(var.skip_rule_associations, k)
  }

  # Filter VPC combinations using the VPC ID key directly
  filtered_vpc_profile_combinations = {
    for k, v in local.vpc_profile_combinations : k => v
    if !contains(var.skip_vpc_associations, k)
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# CloudWatch Log Group for Query Logging
resource "aws_cloudwatch_log_group" "resolver_query_logs" {
  count = var.enable && var.enable_query_logging ? 1 : 0

  name              = "/aws/route53resolver/${local.name_prefix}/query-logs"
  retention_in_days = var.query_log_retention_days

  tags = merge(
    {
      Name        = "${local.name_prefix}-route53-query-logs"
      Environment = var.environment
      Owner       = var.owner
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}

# Route53 Resolver Query Logging Config
resource "aws_route53_resolver_query_log_config" "this" {
  count = var.enable && var.enable_query_logging ? 1 : 0

  name            = "${local.name_prefix}-route53-query-logging"
  destination_arn = aws_cloudwatch_log_group.resolver_query_logs[0].arn

  tags = merge(
    {
      Name        = "${local.name_prefix}-route53-query-logging"
      Environment = var.environment
      Owner       = var.owner
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}

# Associate VPCs with Query Logging Config
resource "aws_route53_resolver_query_log_config_association" "vpc_associations" {
  for_each = var.enable && var.enable_query_logging ? toset(local.unique_vpc_ids) : []

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.this[0].id
  resource_id                  = each.value
}

# Route53 Resolver Configuration for Primary VPC
resource "aws_route53_resolver_config" "primary" {
  count = var.enable ? 1 : 0

  resource_id              = var.primary_vpc_id
  autodefined_reverse_flag = var.autodefined_reverse_flag
}

# Route53 Resolver Configuration for Additional VPCs
resource "aws_route53_resolver_config" "additional" {
  for_each = var.enable ? toset([for vpc_id in var.additional_vpc_ids : vpc_id if vpc_id != var.primary_vpc_id]) : []

  resource_id              = each.value
  autodefined_reverse_flag = var.autodefined_reverse_flag
}

# --- Route53 Profiles ---
# Create a Route53 Profile - only one profile is needed
resource "aws_route53profiles_profile" "main" {
  count = var.enable ? 1 : 0

  name = "${local.name_prefix}-dns-profile"
  tags = merge(
    {
      Name        = "${local.name_prefix}-dns-profile"
      Environment = var.environment
      Owner       = var.owner
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [tags["CreationDate"]]
  }
}

# --- Private Hosted Zone Resource Associations ---
# Associate all private hosted zones with the Route53 Profile
resource "aws_route53profiles_resource_association" "private_zone_associations" {
  for_each = var.enable ? local.filtered_hosted_zone_profile_combinations : {}

  name         = each.value.name
  profile_id   = aws_route53profiles_profile.main[0].id
  resource_arn = each.value.zone_id
}

# --- Resolver Rule Resource Associations ---
# Associate all resolver rules with the Route53 Profile
resource "aws_route53profiles_resource_association" "resolver_rule_associations" {
  for_each = var.enable ? local.filtered_resolver_rule_profile_combinations : {}

  name         = each.value.name
  profile_id   = aws_route53profiles_profile.main[0].id
  resource_arn = each.value.resolver_rule_id

  # Ignore changes to the resource_arn to avoid issues with dynamic resolver rules
  lifecycle {
    ignore_changes = [resource_arn]
  }
}

# --- VPC Profile Associations ---
# Associate the Route53 Profile with all VPCs
resource "aws_route53profiles_association" "vpc_profile_associations" {
  for_each = var.enable ? local.filtered_vpc_profile_combinations : {}

  name        = each.value.name
  profile_id  = aws_route53profiles_profile.main[0].id
  resource_id = each.value.vpc_id
}
