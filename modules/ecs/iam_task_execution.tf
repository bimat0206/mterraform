# Task Execution Role (for ECS agent - pulling images, writing logs, etc.)
resource "aws_iam_role" "task_execution" {
  count = var.create_task_execution_role ? 1 : 0

  name = "${local.cluster_name}-task-execution-role"

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
    {
      Name = "${local.cluster_name}-task-execution-role"
    }
  )
}

# Attach AWS managed ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "task_execution_AmazonECSTaskExecutionRolePolicy" {
  count = var.create_task_execution_role ? 1 : 0

  role       = aws_iam_role.task_execution[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional inline policy for Secrets Manager and SSM Parameter Store access
resource "aws_iam_role_policy" "task_execution_secrets" {
  count = var.create_task_execution_role ? 1 : 0

  name = "${local.cluster_name}-task-execution-secrets"
  role = aws_iam_role.task_execution[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:${local.partition}:secretsmanager:${local.region}:${local.account_id}:secret:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParameterHistory"
        ]
        Resource = [
          "arn:${local.partition}:ssm:${local.region}:${local.account_id}:parameter/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          "arn:${local.partition}:kms:${local.region}:${local.account_id}:key/*"
        ]
      }
    ]
  })
}

# Attach additional policies to task execution role
resource "aws_iam_role_policy_attachment" "task_execution_additional" {
  for_each = var.create_task_execution_role ? toset(var.task_execution_role_policies) : []

  role       = aws_iam_role.task_execution[0].name
  policy_arn = each.value
}
