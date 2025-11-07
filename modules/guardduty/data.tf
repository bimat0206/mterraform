# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition

  # Naming
  service_name = var.service != "" ? var.service : "guardduty"
  name_prefix  = var.identifier != "" ? "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}-${var.identifier}" : "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}"
  name         = "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}"

  # S3 Bucket
  s3_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "${local.name_prefix}-findings"

  # SNS Topic
  sns_topic_name = var.sns_topic_name != "" ? var.sns_topic_name : "${local.name_prefix}-findings"

  # Default CloudWatch Event pattern for medium to high severity findings
  default_event_pattern = {
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = var.finding_severity_filter
    }
  }

  event_pattern = var.cloudwatch_event_rule_pattern != null ? var.cloudwatch_event_rule_pattern : local.default_event_pattern

  # Tags
  common_tags = merge(
    var.tags,
    {
      Module      = "guardduty"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
