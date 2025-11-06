locals {
  # Common tags using the common tag module
  common_tags = merge(
    module.tags.tags,
    {
      Name = var.name
    }
  )

  # Map of VPC attachment IDs
  vpc_attachment_ids = {
    for k, v in var.vpc_attachments : k => aws_ec2_transit_gateway_vpc_attachment.this[k].id
  }

  # Map of VPN attachment IDs
  vpn_attachment_ids = {
    for k, v in var.vpn_attachments : k => v.transit_gateway_attachment_id
  }

  # Combined attachment IDs for route table associations/propagations
  attachment_ids = merge(local.vpc_attachment_ids, local.vpn_attachment_ids)

  # Flatten route table associations
  route_table_associations = flatten([
    for rt_key, rt in var.route_tables : [
      for attachment_key in rt.associations : {
        rt_key         = rt_key
        attachment_key = attachment_key
      }
      if contains(keys(local.attachment_ids), attachment_key)
    ]
  ])

  # Flatten route table propagations
  route_table_propagations = flatten([
    for rt_key, rt in var.route_tables : [
      for attachment_key in rt.propagations : {
        rt_key         = rt_key
        attachment_key = attachment_key
      }
      if contains(keys(local.attachment_ids), attachment_key)
    ]
  ])

  # Flatten static routes
  static_routes = flatten([
    for rt_key, rt in var.route_tables : [
      for route in rt.static_routes : {
        rt_key         = rt_key
        cidr          = route.cidr
        attachment_key = route.attachment_key
      }
      if contains(keys(local.attachment_ids), route.attachment_key)
    ]
  ])
}