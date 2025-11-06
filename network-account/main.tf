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

  # VPC Endpoints Configuration
  enable_s3_endpoint         = var.vpc_enable_s3_endpoint
  enable_dynamodb_endpoint   = var.vpc_enable_dynamodb_endpoint
  enable_interface_endpoints = var.vpc_enable_interface_endpoints

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
