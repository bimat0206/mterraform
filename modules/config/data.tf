# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_organizations_organization" "this" {
  count = var.enable_organization_aggregator ? 1 : 0
}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition

  # Naming
  service_name = var.service != "" ? var.service : "config"
  name_prefix  = var.identifier != "" ? "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}-${var.identifier}" : "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}"
  name         = "${var.org_prefix}-${var.environment}-${var.workload}-${local.service_name}"

  # S3 Bucket
  s3_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "${local.name_prefix}-delivery"

  # SNS Topic
  sns_topic_name = var.sns_topic_name != "" ? var.sns_topic_name : "${local.name_prefix}-notifications"

  # Tags
  common_tags = merge(
    var.tags,
    {
      Module      = "config"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
