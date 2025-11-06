# -----------------------------------------------------------------------------
# Local values
# -----------------------------------------------------------------------------
locals {
  # Common naming inputs for modules
  naming = {
    org_prefix  = var.org_prefix
    environment = var.environment
    workload    = var.workload
  }

  # Common tags for modules
  common_tags = var.tags
}
