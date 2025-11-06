# -----------------------------------------------------------------------------
# IAM Role for Fargate Profiles
# -----------------------------------------------------------------------------
resource "aws_iam_role" "fargate_profile" {
  count = length(var.fargate_profiles) > 0 ? 1 : 0

  name = "${local.name}-fargate-profile-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-fargate-profile-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "fargate_profile_AmazonEKSFargatePodExecutionRolePolicy" {
  count = length(var.fargate_profiles) > 0 ? 1 : 0

  role       = aws_iam_role.fargate_profile[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# -----------------------------------------------------------------------------
# Fargate Profiles
# -----------------------------------------------------------------------------
resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "${local.name}-${each.key}"
  pod_execution_role_arn = aws_iam_role.fargate_profile[0].arn
  subnet_ids             = each.value.subnet_ids

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value.namespace
      labels    = selector.value.labels
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = "${local.name}-${each.key}"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.fargate_profile_AmazonEKSFargatePodExecutionRolePolicy
  ]
}
