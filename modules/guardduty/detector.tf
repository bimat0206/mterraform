# -----------------------------------------------------------------------------
# GuardDuty Detector
# -----------------------------------------------------------------------------
resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }

    kubernetes {
      audit_logs {
        enable = var.enable_eks_protection
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.name
    }
  )
}

# -----------------------------------------------------------------------------
# GuardDuty Detector Features (RDS and Lambda Protection)
# -----------------------------------------------------------------------------
# Note: RDS and Lambda protection are managed separately from datasources

resource "aws_guardduty_detector_feature" "rds_login_events" {
  count = var.enable_guardduty && var.enable_rds_protection ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  count = var.enable_guardduty && var.enable_lambda_protection ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  count = var.enable_guardduty && var.enable_eks_protection ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}
