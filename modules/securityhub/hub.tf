# -----------------------------------------------------------------------------
# AWS Security Hub Account
# -----------------------------------------------------------------------------
resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards  = var.enable_default_standards
  control_finding_generator = var.control_finding_generator

  depends_on = [aws_securityhub_organization_admin_account.this]
}

# -----------------------------------------------------------------------------
# Security Hub Organization Configuration
# -----------------------------------------------------------------------------
resource "aws_securityhub_organization_admin_account" "this" {
  count = var.enable_security_hub && var.enable_organization_admin_account ? 1 : 0

  admin_account_id = local.account_id
}

resource "aws_securityhub_organization_configuration" "this" {
  count = var.enable_security_hub && var.enable_organization_admin_account ? 1 : 0

  auto_enable           = var.auto_enable_organization_members
  auto_enable_standards = var.auto_enable_default_standards ? "DEFAULT" : "NONE"

  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [
    aws_securityhub_organization_admin_account.this,
    aws_securityhub_account.this
  ]
}

# -----------------------------------------------------------------------------
# Security Hub Finding Aggregator
# -----------------------------------------------------------------------------
resource "aws_securityhub_finding_aggregator" "this" {
  count = var.enable_security_hub && var.enable_finding_aggregator ? 1 : 0

  linking_mode = var.aggregator_linking_mode

  dynamic "regions" {
    for_each = var.aggregator_linking_mode == "SPECIFIED_REGIONS" && length(var.aggregator_regions) > 0 ? [1] : []
    content {
      regions = var.aggregator_regions
    }
  }

  depends_on = [aws_securityhub_account.this]
}
