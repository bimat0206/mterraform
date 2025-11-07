# -----------------------------------------------------------------------------
# GuardDuty Organization Configuration
# -----------------------------------------------------------------------------
resource "aws_guardduty_organization_admin_account" "this" {
  count = var.enable_guardduty && var.enable_organization_admin_account ? 1 : 0

  admin_account_id = local.account_id

  depends_on = [aws_guardduty_detector.this]
}

resource "aws_guardduty_organization_configuration" "this" {
  count = var.enable_guardduty && var.enable_organization_admin_account ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  auto_enable = var.auto_enable_organization_members

  datasources {
    s3_logs {
      auto_enable = var.enable_s3_protection && var.auto_enable_organization_members
    }

    kubernetes {
      audit_logs {
        enable = var.enable_eks_protection && var.auto_enable_organization_members
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.enable_malware_protection && var.auto_enable_organization_members
        }
      }
    }
  }

  depends_on = [
    aws_guardduty_organization_admin_account.this
  ]
}

# Auto-enable organization configuration features
resource "aws_guardduty_organization_configuration_feature" "rds" {
  count = var.enable_guardduty && var.enable_organization_admin_account && var.enable_rds_protection ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "RDS_LOGIN_EVENTS"
  auto_enable = var.auto_enable_organization_members ? "ALL" : "NONE"

  depends_on = [
    aws_guardduty_organization_configuration.this
  ]
}

resource "aws_guardduty_organization_configuration_feature" "lambda" {
  count = var.enable_guardduty && var.enable_organization_admin_account && var.enable_lambda_protection ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "LAMBDA_NETWORK_LOGS"
  auto_enable = var.auto_enable_organization_members ? "ALL" : "NONE"

  depends_on = [
    aws_guardduty_organization_configuration.this
  ]
}

resource "aws_guardduty_organization_configuration_feature" "eks_runtime" {
  count = var.enable_guardduty && var.enable_organization_admin_account && var.enable_eks_protection ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "EKS_RUNTIME_MONITORING"
  auto_enable = var.auto_enable_organization_members ? "ALL" : "NONE"

  additional_configuration {
    name        = "EKS_ADDON_MANAGEMENT"
    auto_enable = var.auto_enable_organization_members ? "ALL" : "NONE"
  }

  depends_on = [
    aws_guardduty_organization_configuration.this
  ]
}
