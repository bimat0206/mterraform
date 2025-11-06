# -----------------------------------------------------------------------------
# EKS Access Entries (IAM to Kubernetes RBAC Mapping)
# -----------------------------------------------------------------------------
# Note: EKS Access Entries are the modern replacement for aws-auth ConfigMap
# They provide a managed way to map IAM principals to Kubernetes RBAC

# Map IAM Roles to Kubernetes RBAC
resource "aws_eks_access_entry" "roles" {
  for_each = { for idx, role in var.aws_auth_roles : idx => role }

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.rolearn
  kubernetes_groups = each.value.groups
  type              = "STANDARD"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-access-role-${each.key}"
    }
  )
}

# Map IAM Users to Kubernetes RBAC
resource "aws_eks_access_entry" "users" {
  for_each = { for idx, user in var.aws_auth_users : idx => user }

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.userarn
  kubernetes_groups = each.value.groups
  type              = "STANDARD"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-access-user-${each.key}"
    }
  )
}

# Map IAM Groups to Kubernetes RBAC
# Note: IAM groups need to be accessed via assumed roles
# Users in the IAM group must assume a role to access the cluster
resource "aws_iam_role" "group_access" {
  for_each = var.map_iam_groups

  name = "${local.name}-${each.key}-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = each.value.iam_group_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name}-${each.key}-access-role"
      Description = "Role for IAM group ${each.key} to access EKS cluster"
    }
  )
}

resource "aws_eks_access_entry" "groups" {
  for_each = var.map_iam_groups

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = aws_iam_role.group_access[each.key].arn
  kubernetes_groups = each.value.k8s_groups
  type              = "STANDARD"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-access-group-${each.key}"
    }
  )
}
