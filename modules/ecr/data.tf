data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  # Common naming prefix
  name_prefix = "${var.org_prefix}-${var.environment}-${var.workload}"

  # Merge common tags with module tags
  common_tags = merge(
    var.tags,
    {
      Module      = "ecr"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
