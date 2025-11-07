# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# Available product integrations
data "aws_securityhub_available_standards" "this" {
  count = var.enable_security_hub ? 1 : 0
}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition

  # Naming
  service_name = var.service != "" ? var.service : "securityhub"
  name_prefix  = var.identifier != "" ? "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}-${var.identifier}" : "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}"
  name         = "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}"

  # SNS Topic
  sns_topic_name = var.sns_topic_name != "" ? var.sns_topic_name : "${local.name_prefix}-findings"

  # Security Standards ARNs
  cis_standard_arn = "arn:${local.partition}:securityhub:${local.region}::standards/cis-aws-foundations-benchmark/v/${var.cis_standard_version}"
  aws_foundational_standard_arn = "arn:${local.partition}:securityhub:${local.region}::standards/aws-foundational-security-best-practices/v/${var.aws_foundational_standard_version}"
  pci_dss_standard_arn = "arn:${local.partition}:securityhub:${local.region}::standards/pci-dss/v/${var.pci_dss_standard_version}"
  nist_standard_arn = "arn:${local.partition}:securityhub:${local.region}::standards/nist-800-53/v/${var.nist_standard_version}"

  # Product ARNs for automatic integration
  default_product_arns = var.enable_product_integrations && length(var.product_arns) == 0 ? [
    "arn:${local.partition}:securityhub:${local.region}::product/aws/guardduty",
    "arn:${local.partition}:securityhub:${local.region}::product/aws/config",
    "arn:${local.partition}:securityhub:${local.region}::product/aws/inspector",
    "arn:${local.partition}:securityhub:${local.region}::product/aws/access-analyzer",
    "arn:${local.partition}:securityhub:${local.region}::product/aws/macie",
    "arn:${local.partition}:securityhub:${local.region}::product/aws/firewall-manager",
  ] : var.product_arns

  # Default CloudWatch Event pattern for findings
  default_event_pattern = {
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        Severity = {
          Label = var.finding_severity_filter
        }
        Workflow = {
          Status = var.workflow_status_filter
        }
      }
    }
  }

  event_pattern = var.cloudwatch_event_rule_pattern != null ? var.cloudwatch_event_rule_pattern : local.default_event_pattern

  # Tags
  common_tags = merge(
    var.tags,
    {
      Module      = "securityhub"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
