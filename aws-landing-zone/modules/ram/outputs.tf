# Transit Gateway Share Outputs
output "transit_gateway_share_id" {
  description = "The ID of the Transit Gateway resource share"
  value       = local.create_transit_gateway_share ? aws_ram_resource_share.transit_gateway[0].id : null
}

output "transit_gateway_share_arn" {
  description = "The ARN of the Transit Gateway resource share"
  value       = local.create_transit_gateway_share ? aws_ram_resource_share.transit_gateway[0].arn : null
}

output "transit_gateway_share_name" {
  description = "The name of the Transit Gateway resource share"
  value       = local.create_transit_gateway_share ? aws_ram_resource_share.transit_gateway[0].name : null
}

# Route53 Profile Share Outputs
output "route53_profile_share_id" {
  description = "The ID of the Route53 Profile resource share"
  value       = local.create_route53_profile_share ? aws_ram_resource_share.route53_profile[0].id : null
}

output "route53_profile_share_arn" {
  description = "The ARN of the Route53 Profile resource share"
  value       = local.create_route53_profile_share ? aws_ram_resource_share.route53_profile[0].arn : null
}

output "route53_profile_share_name" {
  description = "The name of the Route53 Profile resource share"
  value       = local.create_route53_profile_share ? aws_ram_resource_share.route53_profile[0].name : null
}

# Query Logging Share Outputs
output "query_logging_share_id" {
  description = "The ID of the Query Logging resource share"
  value       = local.create_query_logging_share ? aws_ram_resource_share.query_logging[0].id : null
}

output "query_logging_share_arn" {
  description = "The ARN of the Query Logging resource share"
  value       = local.create_query_logging_share ? aws_ram_resource_share.query_logging[0].arn : null
}

output "query_logging_share_name" {
  description = "The name of the Query Logging resource share"
  value       = local.create_query_logging_share ? aws_ram_resource_share.query_logging[0].name : null
}

# Associated Resources
output "transit_gateway_associated_resource_arns" {
  description = "List of ARNs of the Transit Gateway resources associated with the share"
  value       = local.create_transit_gateway_share ? [for assoc in aws_ram_resource_association.transit_gateway : assoc.resource_arn] : []
}

output "route53_profile_associated_resource_arns" {
  description = "List of ARNs of the Route53 Profile resources associated with the share"
  value       = local.create_route53_profile_share ? [for assoc in aws_ram_resource_association.route53_profile : assoc.resource_arn] : []
}

output "query_logging_associated_resource_arns" {
  description = "List of ARNs of the Query Logging resources associated with the share"
  value       = local.create_query_logging_share ? [for assoc in aws_ram_resource_association.query_logging : assoc.resource_arn] : []
}

output "query_logging_associations" {
  description = "Map of Query Logging resource associations"
  value       = aws_ram_resource_association.query_logging
}

# Associated Principals
output "transit_gateway_associated_principals" {
  description = "List of principals associated with the Transit Gateway share"
  value = local.create_transit_gateway_share ? concat(
    [for assoc in aws_ram_principal_association.transit_gateway_organizational_units : assoc.principal],
    [for assoc in aws_ram_principal_association.transit_gateway_accounts : assoc.principal],
    [for assoc in aws_ram_principal_association.transit_gateway_organizations : assoc.principal]
  ) : []
}

output "route53_profile_associated_principals" {
  description = "List of principals associated with the Route53 Profile share"
  value = local.create_route53_profile_share ? concat(
    [for assoc in aws_ram_principal_association.route53_profile_organizational_units : assoc.principal],
    [for assoc in aws_ram_principal_association.route53_profile_accounts : assoc.principal],
    [for assoc in aws_ram_principal_association.route53_profile_organizations : assoc.principal]
  ) : []
}

output "query_logging_associated_principals" {
  description = "List of principals associated with the Query Logging share"
  value = local.create_query_logging_share ? concat(
    [for assoc in aws_ram_principal_association.query_logging_organizational_units : assoc.principal],
    [for assoc in aws_ram_principal_association.query_logging_accounts : assoc.principal],
    [for assoc in aws_ram_principal_association.query_logging_organizations : assoc.principal]
  ) : []
}

# For backward compatibility
output "resource_share_id" {
  description = "The ID of the first available resource share (for backward compatibility)"
  value = coalesce(
    local.create_transit_gateway_share ? aws_ram_resource_share.transit_gateway[0].id : null,
    local.create_route53_profile_share ? aws_ram_resource_share.route53_profile[0].id : null,
    local.create_query_logging_share ? aws_ram_resource_share.query_logging[0].id : null,
    ""
  )
}

output "resource_share_arn" {
  description = "The ARN of the first available resource share (for backward compatibility)"
  value = coalesce(
    local.create_transit_gateway_share ? aws_ram_resource_share.transit_gateway[0].arn : null,
    local.create_route53_profile_share ? aws_ram_resource_share.route53_profile[0].arn : null,
    local.create_query_logging_share ? aws_ram_resource_share.query_logging[0].arn : null,
    ""
  )
}

output "resource_share_name" {
  description = "The name of the first available resource share (for backward compatibility)"
  value = coalesce(
    local.create_transit_gateway_share ? aws_ram_resource_share.transit_gateway[0].name : null,
    local.create_route53_profile_share ? aws_ram_resource_share.route53_profile[0].name : null,
    local.create_query_logging_share ? aws_ram_resource_share.query_logging[0].name : null,
    ""
  )
}

output "associated_resource_arns" {
  description = "List of ARNs of all resources associated with all shares (for backward compatibility)"
  value = concat(
    local.create_transit_gateway_share ? [for assoc in aws_ram_resource_association.transit_gateway : assoc.resource_arn] : [],
    local.create_route53_profile_share ? [for assoc in aws_ram_resource_association.route53_profile : assoc.resource_arn] : [],
    local.create_query_logging_share ? [for assoc in aws_ram_resource_association.query_logging : assoc.resource_arn] : []
  )
}

output "associated_principals" {
  description = "List of all principals associated with all shares (for backward compatibility)"
  value = concat(
    local.create_transit_gateway_share ? concat(
      [for assoc in aws_ram_principal_association.transit_gateway_organizational_units : assoc.principal],
      [for assoc in aws_ram_principal_association.transit_gateway_accounts : assoc.principal],
      [for assoc in aws_ram_principal_association.transit_gateway_organizations : assoc.principal]
    ) : [],
    local.create_route53_profile_share ? concat(
      [for assoc in aws_ram_principal_association.route53_profile_organizational_units : assoc.principal],
      [for assoc in aws_ram_principal_association.route53_profile_accounts : assoc.principal],
      [for assoc in aws_ram_principal_association.route53_profile_organizations : assoc.principal]
    ) : [],
    local.create_query_logging_share ? concat(
      [for assoc in aws_ram_principal_association.query_logging_organizational_units : assoc.principal],
      [for assoc in aws_ram_principal_association.query_logging_accounts : assoc.principal],
      [for assoc in aws_ram_principal_association.query_logging_organizations : assoc.principal]
    ) : []
  )
}
