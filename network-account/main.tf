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

  # VPC configuration
  cidr_block         = var.vpc_cidr_block
  az_count           = var.vpc_az_count
  enable_nat_gateway = var.vpc_enable_nat_gateway

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
