# Task Roles (for application-level permissions)
resource "aws_iam_role" "task_role" {
  for_each = {
    for k, v in var.task_definitions : k => v
    if v.task_role_arn == null && (length(v.task_role_policies) > 0 || length(v.task_role_policy_statements) > 0)
  }

  name = "${local.cluster_name}-${each.key}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name        = "${local.cluster_name}-${each.key}-task-role"
      TaskFamily  = each.key
    }
  )
}

# Attach managed policies to task roles
resource "aws_iam_role_policy_attachment" "task_role" {
  for_each = {
    for pair in flatten([
      for k, v in var.task_definitions : [
        for policy in v.task_role_policies : {
          key        = "${k}-${replace(policy, "/", "-")}"
          role_key   = k
          policy_arn = policy
        }
      ] if v.task_role_arn == null && length(v.task_role_policies) > 0
    ]) : pair.key => pair
  }

  role       = aws_iam_role.task_role[each.value.role_key].name
  policy_arn = each.value.policy_arn
}

# Create inline policies for task roles
resource "aws_iam_role_policy" "task_role" {
  for_each = {
    for k, v in var.task_definitions : k => v
    if v.task_role_arn == null && length(v.task_role_policy_statements) > 0
  }

  name = "${local.cluster_name}-${each.key}-task-policy"
  role = aws_iam_role.task_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in each.value.task_role_policy_statements : {
        Effect    = stmt.effect
        Action    = stmt.actions
        Resource  = stmt.resources
      }
    ]
  })
}
