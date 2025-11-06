# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
locals {
  # Naming convention
  naming = {
    org_prefix  = var.org_prefix
    environment = var.environment
    workload    = var.workload
  }

  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Organization = var.org_prefix
      Environment  = var.environment
      Workload     = var.workload
      ManagedBy    = "Terraform"
      Account      = "Management"
    }
  )
}
