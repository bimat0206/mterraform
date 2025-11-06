data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  # Cluster name
  cluster_name = var.cluster_name != "" ? var.cluster_name : "${var.org_prefix}-${var.environment}-${var.workload}"

  # CloudWatch log group prefix
  log_group_prefix = "/ecs/${local.cluster_name}"

  # Merge common tags with module tags
  common_tags = merge(
    var.tags,
    {
      Module      = "ecs"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # Build capacity provider list
  capacity_providers = concat(
    var.enable_fargate ? ["FARGATE"] : [],
    var.enable_fargate_spot ? ["FARGATE_SPOT"] : []
  )
}
