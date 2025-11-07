# -----------------------------------------------------------------------------
# AWS Config Organization Aggregator
# -----------------------------------------------------------------------------
resource "aws_config_configuration_aggregator" "organization" {
  count = var.enable_organization_aggregator ? 1 : 0

  name = "${local.name}-org-aggregator"

  organization_aggregation_source {
    all_regions = length(var.aggregator_regions) == 0 ? true : false
    regions     = length(var.aggregator_regions) > 0 ? var.aggregator_regions : null
    role_arn    = var.create_iam_role ? aws_iam_role.config[0].arn : var.iam_role_arn
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-org-aggregator"
    }
  )

  depends_on = [
    aws_iam_role_policy.config_organization,
    aws_config_configuration_recorder_status.this
  ]
}
