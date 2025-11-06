# -----------------------------------------------------------------------------
# VPC Module
# -----------------------------------------------------------------------------
module "vpc" {
  source = "../modules/vpc"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "vpc"
  identifier  = "01"

  # VPC Basic Configuration
  cidr_block            = var.vpc_cidr_block
  secondary_cidr_blocks = var.vpc_secondary_cidr_blocks
  enable_ipv6           = var.vpc_enable_ipv6
  instance_tenancy      = var.vpc_instance_tenancy

  # DNS Configuration
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support

  # Subnet Configuration
  az_count                     = var.vpc_az_count
  public_subnet_suffix         = var.vpc_public_subnet_suffix
  private_subnet_suffix        = var.vpc_private_subnet_suffix
  database_subnet_suffix       = var.vpc_database_subnet_suffix
  create_database_subnets      = var.vpc_create_database_subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group
  map_public_ip_on_launch      = var.vpc_map_public_ip_on_launch

  # NAT Gateway Configuration
  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

  # VPN Gateway Configuration
  enable_vpn_gateway                            = var.vpc_enable_vpn_gateway
  vpn_gateway_az                                = var.vpc_vpn_gateway_az
  propagate_vpn_routes_to_private_route_tables  = var.vpc_propagate_vpn_routes_to_private_route_tables
  propagate_vpn_routes_to_public_route_tables   = var.vpc_propagate_vpn_routes_to_public_route_tables

  # VPC Flow Logs Configuration
  enable_flow_logs              = var.vpc_enable_flow_logs
  flow_logs_destination_type    = var.vpc_flow_logs_destination_type
  flow_logs_destination_arn     = var.vpc_flow_logs_destination_arn
  flow_logs_traffic_type        = var.vpc_flow_logs_traffic_type
  flow_logs_retention_days      = var.vpc_flow_logs_retention_days

  # DHCP Options Configuration
  enable_dhcp_options              = var.vpc_enable_dhcp_options
  dhcp_options_domain_name         = var.vpc_dhcp_options_domain_name
  dhcp_options_domain_name_servers = var.vpc_dhcp_options_domain_name_servers
  dhcp_options_ntp_servers         = var.vpc_dhcp_options_ntp_servers
  dhcp_options_netbios_name_servers = var.vpc_dhcp_options_netbios_name_servers
  dhcp_options_netbios_node_type   = var.vpc_dhcp_options_netbios_node_type

  # Network ACL Configuration
  manage_default_network_acl   = var.vpc_manage_default_network_acl
  default_network_acl_ingress  = var.vpc_default_network_acl_ingress
  default_network_acl_egress   = var.vpc_default_network_acl_egress
  public_dedicated_network_acl = var.vpc_public_dedicated_network_acl
  private_dedicated_network_acl = var.vpc_private_dedicated_network_acl

  # Default Security Group Configuration
  manage_default_security_group   = var.vpc_manage_default_security_group
  default_security_group_ingress  = var.vpc_default_security_group_ingress
  default_security_group_egress   = var.vpc_default_security_group_egress

  # Default Route Table Configuration
  manage_default_route_table = var.vpc_manage_default_route_table
  default_route_table_routes = var.vpc_default_route_table_routes

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# VPC Gateway Endpoints Module (optional)
# -----------------------------------------------------------------------------
module "vpc_gateway_endpoints" {
  count  = var.vpce_gateway_enabled ? 1 : 0
  source = "../modules/vpc-endpoint-gateway"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  identifier  = "01"

  # VPC Configuration
  vpc_id = module.vpc.vpc_id

  # Gateway Endpoints
  enable_s3_endpoint       = var.vpce_enable_s3_endpoint
  enable_dynamodb_endpoint = var.vpce_enable_dynamodb_endpoint

  # Route Tables
  route_table_ids = concat(
    [module.vpc.public_route_table_id],
    module.vpc.private_route_table_ids
  )

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# VPC Interface Endpoints Module (optional)
# -----------------------------------------------------------------------------
module "vpc_interface_endpoints" {
  count  = var.vpce_interface_enabled && length(var.vpce_interface_endpoints) > 0 ? 1 : 0
  source = "../modules/vpc-endpoint-interface"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  identifier  = "01"

  # VPC Configuration
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  # Interface Endpoints
  endpoints           = var.vpce_interface_endpoints
  private_dns_enabled = var.vpce_private_dns_enabled

  # Security Group
  create_security_group = true

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ACM Module (optional)
# -----------------------------------------------------------------------------
module "acm" {
  count  = var.acm_enabled ? 1 : 0
  source = "../modules/acm"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "acm"
  identifier  = "01"

  # ACM configuration
  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  hosted_zone_id            = var.acm_hosted_zone_id

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ALB Module (optional)
# -----------------------------------------------------------------------------
module "alb" {
  count  = var.alb_enabled ? 1 : 0
  source = "../modules/alb"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "alb"
  identifier  = "01"

  # VPC Configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = var.alb_internal ? module.vpc.private_subnet_ids : module.vpc.public_subnet_ids

  # ALB Configuration
  internal                       = var.alb_internal
  enable_deletion_protection     = var.alb_enable_deletion_protection
  enable_http2                   = var.alb_enable_http2
  enable_cross_zone_load_balancing = var.alb_enable_cross_zone_load_balancing
  idle_timeout                   = var.alb_idle_timeout
  drop_invalid_header_fields     = var.alb_drop_invalid_header_fields

  # S3 Logging Configuration
  enable_access_logs          = var.alb_enable_access_logs
  create_s3_bucket            = var.alb_create_s3_bucket
  s3_bucket_prefix            = var.alb_s3_bucket_prefix
  log_bucket_lifecycle_days   = var.alb_log_bucket_lifecycle_days
  log_bucket_expiration_days  = var.alb_log_bucket_expiration_days

  # Target Groups
  target_groups = var.alb_target_groups

  # Listeners
  listeners = var.alb_listeners

  # Security Group
  create_security_group             = true
  security_group_ingress_rules      = var.alb_security_group_ingress_rules

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Transit Gateway Module (optional)
# -----------------------------------------------------------------------------
module "transit_gateway" {
  count  = var.tgw_enabled ? 1 : 0
  source = "../modules/transit-gateway"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "tgw"
  identifier  = "01"

  # Transit Gateway Configuration
  description                     = var.tgw_description
  amazon_side_asn                 = var.tgw_amazon_side_asn
  auto_accept_shared_attachments  = var.tgw_auto_accept_shared_attachments
  default_route_table_association = var.tgw_default_route_table_association
  default_route_table_propagation = var.tgw_default_route_table_propagation
  dns_support                     = var.tgw_dns_support
  vpn_ecmp_support                = var.tgw_vpn_ecmp_support
  multicast_support               = var.tgw_multicast_support
  transit_gateway_cidr_blocks     = var.tgw_cidr_blocks

  # VPC Attachments
  vpc_attachments = var.tgw_vpc_attachments

  # Custom Route Tables
  create_custom_route_tables = var.tgw_create_custom_route_tables
  custom_route_tables        = var.tgw_custom_route_tables

  # Flow Logs
  enable_flow_logs                     = var.tgw_enable_flow_logs
  flow_logs_destination_type           = var.tgw_flow_logs_destination_type
  flow_logs_s3_bucket_arn              = var.tgw_flow_logs_s3_bucket_arn
  flow_logs_retention_days             = var.tgw_flow_logs_retention_days
  flow_logs_max_aggregation_interval   = var.tgw_flow_logs_max_aggregation_interval
  create_flow_logs_iam_role            = var.tgw_create_flow_logs_iam_role

  # CloudWatch Alarms
  enable_cloudwatch_alarms              = var.tgw_enable_cloudwatch_alarms
  alarm_sns_topic_arn                   = var.tgw_alarm_sns_topic_arn
  bytes_in_threshold                    = var.tgw_bytes_in_threshold
  bytes_out_threshold                   = var.tgw_bytes_out_threshold
  packet_drop_count_blackhole_threshold = var.tgw_packet_drop_count_blackhole_threshold
  packet_drop_count_no_route_threshold  = var.tgw_packet_drop_count_no_route_threshold

  # Resource Sharing
  enable_resource_sharing       = var.tgw_enable_resource_sharing
  ram_principals                = var.tgw_ram_principals
  ram_allow_external_principals = var.tgw_ram_allow_external_principals

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# WAF Module (optional)
# -----------------------------------------------------------------------------
module "waf" {
  count  = var.waf_enabled ? 1 : 0
  source = "../modules/waf"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = var.waf_service_name
  identifier  = var.waf_identifier

  # WAF Configuration
  scope          = var.waf_scope
  default_action = var.waf_default_action
  description    = var.waf_description

  # AWS Managed Rules
  enable_aws_managed_rules      = var.waf_enable_aws_managed_rules
  enable_core_rule_set          = var.waf_enable_core_rule_set
  enable_known_bad_inputs       = var.waf_enable_known_bad_inputs
  enable_sql_injection          = var.waf_enable_sql_injection
  enable_linux_os               = var.waf_enable_linux_os
  enable_unix_os                = var.waf_enable_unix_os
  enable_windows_os             = var.waf_enable_windows_os
  enable_php_app                = var.waf_enable_php_app
  enable_wordpress_app          = var.waf_enable_wordpress_app
  enable_amazon_ip_reputation   = var.waf_enable_amazon_ip_reputation
  enable_anonymous_ip_list      = var.waf_enable_anonymous_ip_list
  enable_bot_control            = var.waf_enable_bot_control
  bot_control_inspection_level  = var.waf_bot_control_inspection_level

  # Custom Rules - IP Sets
  ip_allowlist = var.waf_ip_allowlist
  ip_blocklist = var.waf_ip_blocklist

  # Custom Rules - Rate Limiting
  enable_rate_limiting = var.waf_enable_rate_limiting
  rate_limit           = var.waf_rate_limit
  rate_limit_action    = var.waf_rate_limit_action

  # Custom Rules - Geographic Blocking
  enable_geo_blocking   = var.waf_enable_geo_blocking
  geo_blocked_countries = var.waf_geo_blocked_countries

  # Logging
  enable_logging       = var.waf_enable_logging
  log_destination_type = var.waf_log_destination_type
  log_retention_days   = var.waf_log_retention_days
  s3_bucket_arn        = var.waf_s3_bucket_arn
  kinesis_firehose_arn = var.waf_kinesis_firehose_arn
  redacted_fields      = var.waf_redacted_fields

  # Resource Associations
  associated_alb_arns         = var.waf_associated_alb_arns
  associated_api_gateway_arns = var.waf_associated_api_gateway_arns
  associated_appsync_arns     = var.waf_associated_appsync_arns

  # CloudWatch Metrics
  enable_cloudwatch_metrics = var.waf_enable_cloudwatch_metrics
  metric_name_prefix        = var.waf_metric_name_prefix

  # Tags
  tags = local.common_tags
}
