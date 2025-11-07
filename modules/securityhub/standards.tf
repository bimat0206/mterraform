# -----------------------------------------------------------------------------
# CIS AWS Foundations Benchmark
# -----------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_security_hub && var.enable_cis_standard ? 1 : 0

  standards_arn = local.cis_standard_arn

  depends_on = [aws_securityhub_account.this]
}

# -----------------------------------------------------------------------------
# AWS Foundational Security Best Practices
# -----------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_security_hub && var.enable_aws_foundational_standard ? 1 : 0

  standards_arn = local.aws_foundational_standard_arn

  depends_on = [aws_securityhub_account.this]
}

# -----------------------------------------------------------------------------
# PCI DSS
# -----------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "pci_dss" {
  count = var.enable_security_hub && var.enable_pci_dss_standard ? 1 : 0

  standards_arn = local.pci_dss_standard_arn

  depends_on = [aws_securityhub_account.this]
}

# -----------------------------------------------------------------------------
# NIST SP 800-53 Rev. 5
# -----------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "nist" {
  count = var.enable_security_hub && var.enable_nist_standard ? 1 : 0

  standards_arn = local.nist_standard_arn

  depends_on = [aws_securityhub_account.this]
}
