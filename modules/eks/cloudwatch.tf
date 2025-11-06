# -----------------------------------------------------------------------------
# CloudWatch Log Group for Control Plane Logs
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cluster" {
  count = length(var.enabled_cluster_log_types) > 0 ? 1 : 0

  name              = "/aws/eks/${local.name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-cluster-logs"
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Container Insights - Log Groups
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "container_insights" {
  count = var.enable_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${local.name}/application"
  retention_in_days = var.container_insights_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-container-insights"
    }
  )
}

resource "aws_cloudwatch_log_group" "container_insights_performance" {
  count = var.enable_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${local.name}/performance"
  retention_in_days = var.container_insights_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-container-insights-performance"
    }
  )
}

resource "aws_cloudwatch_log_group" "container_insights_dataplane" {
  count = var.enable_container_insights ? 1 : 0

  name              = "/aws/containerinsights/${local.name}/dataplane"
  retention_in_days = var.container_insights_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-container-insights-dataplane"
    }
  )
}
