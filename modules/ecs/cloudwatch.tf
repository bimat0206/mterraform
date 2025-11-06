# CloudWatch Log Groups for ECS Tasks
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.create_cloudwatch_log_groups ? var.task_definitions : {}

  name              = "${local.log_group_prefix}/${each.key}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name       = "${local.log_group_prefix}/${each.key}"
      TaskKey    = each.key
    }
  )
}
