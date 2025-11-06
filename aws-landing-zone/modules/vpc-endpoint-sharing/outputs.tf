output "endpoint_hosted_zones" {
  description = "Map of service names to their Route 53 private hosted zone IDs"
  value = {
    "ec2"                  = length(aws_route53_zone.ec2_zone) > 0 ? aws_route53_zone.ec2_zone[0].zone_id : null
    "ec2messages"          = length(aws_route53_zone.ec2messages_zone) > 0 ? aws_route53_zone.ec2messages_zone[0].zone_id : null
    "logs"                 = length(aws_route53_zone.logs_zone) > 0 ? aws_route53_zone.logs_zone[0].zone_id : null
    "ssm"                  = length(aws_route53_zone.ssm_zone) > 0 ? aws_route53_zone.ssm_zone[0].zone_id : null
    "elasticloadbalancing" = length(aws_route53_zone.elasticloadbalancing_zone) > 0 ? aws_route53_zone.elasticloadbalancing_zone[0].zone_id : null
    "ssmmessages"          = length(aws_route53_zone.ssmmessages_zone) > 0 ? aws_route53_zone.ssmmessages_zone[0].zone_id : null
    "s3"                   = length(aws_route53_zone.s3_zone) > 0 ? aws_route53_zone.s3_zone[0].zone_id : null
  }
}

output "s3_hosted_zone_id" {
  description = "The ID of the S3 private hosted zone, if it exists"
  value       = length(aws_route53_zone.s3_zone) > 0 ? aws_route53_zone.s3_zone[0].zone_id : null
}

output "endpoint_zone_associations" {
  description = "Map of associations between private hosted zones and consumer VPCs"
  value = merge(
    { for key, assoc in aws_route53_zone_association.ec2_zone_association : "ec2-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } },
    { for key, assoc in aws_route53_zone_association.ec2messages_zone_association : "ec2messages-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } },
    { for key, assoc in aws_route53_zone_association.logs_zone_association : "logs-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } },
    { for key, assoc in aws_route53_zone_association.ssm_zone_association : "ssm-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } },
    { for key, assoc in aws_route53_zone_association.elasticloadbalancing_zone_association : "elasticloadbalancing-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } },
    { for key, assoc in aws_route53_zone_association.ssmmessages_zone_association : "ssmmessages-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } },
    { for key, assoc in aws_route53_zone_association.s3_zone_association : "s3-${key}" => { zone_id = assoc.zone_id, vpc_id = assoc.vpc_id } }
  )
}

output "s3_zone_associations" {
  description = "Map of associations between the S3 private hosted zone and consumer VPCs"
  value = {
    for key, association in aws_route53_zone_association.s3_zone_association :
    key => {
      zone_id = association.zone_id
      vpc_id  = association.vpc_id
    }
  }
}

output "shared_endpoints" {
  description = "List of endpoint services that are being shared"
  value = compact([
    length(aws_route53_zone.ec2_zone) > 0 ? "ec2" : "",
    length(aws_route53_zone.ec2messages_zone) > 0 ? "ec2messages" : "",
    length(aws_route53_zone.logs_zone) > 0 ? "logs" : "",
    length(aws_route53_zone.ssm_zone) > 0 ? "ssm" : "",
    length(aws_route53_zone.elasticloadbalancing_zone) > 0 ? "elasticloadbalancing" : "",
    length(aws_route53_zone.ssmmessages_zone) > 0 ? "ssmmessages" : "",
    length(aws_route53_zone.s3_zone) > 0 ? "s3" : "",
    length(aws_route53_zone.guardduty_zone) > 0 ? "guardduty" : ""
  ])
}

output "consumer_vpcs" {
  description = "List of consumer VPC IDs that have access to the shared endpoints"
  value       = var.consumer_vpc_ids
}
