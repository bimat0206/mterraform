# -----------------------------------------------------------------------------
# Dynamic naming and tagging locals
# -----------------------------------------------------------------------------
locals {
  # Pick module default service if not provided
  _service = coalesce(var.service, "vpce-gw")

  # Join tokens, drop empties
  _tokens = compact([var.org_prefix, var.environment, var.workload, local._service, var.identifier])
  _raw    = join("-", local._tokens)

  # Normalize to AWS-friendly style: lowercase + hyphens only
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")
}

# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# S3 Gateway Endpoint
# -----------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = var.route_table_ids
  policy          = var.s3_endpoint_policy

  tags = merge(var.tags, {
    Name = "${local.name}-s3"
  })
}

# -----------------------------------------------------------------------------
# DynamoDB Gateway Endpoint
# -----------------------------------------------------------------------------
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = var.route_table_ids
  policy          = var.dynamodb_endpoint_policy

  tags = merge(var.tags, {
    Name = "${local.name}-dynamodb"
  })
}
