# -----------------------------------------------------------------------------
# EKS Add-ons
# -----------------------------------------------------------------------------
resource "aws_eks_addon" "vpc_cni" {
  count = var.enable_vpc_cni_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_addon_version != "" ? var.vpc_cni_addon_version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-cni"
    }
  )

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "coredns" {
  count = var.enable_coredns_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "coredns"
  addon_version            = var.coredns_addon_version != "" ? var.coredns_addon_version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-coredns"
    }
  )

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.enable_kube_proxy_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "kube-proxy"
  addon_version            = var.kube_proxy_addon_version != "" ? var.kube_proxy_addon_version : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-kube-proxy"
    }
  )

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.enable_ebs_csi_driver_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_driver_addon_version != "" ? var.ebs_csi_driver_addon_version : null
  service_account_role_arn = var.enable_irsa ? aws_iam_role.ebs_csi_driver[0].arn : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ebs-csi-driver"
    }
  )

  depends_on = [
    aws_eks_node_group.this,
    aws_iam_role_policy_attachment.ebs_csi_driver
  ]
}

resource "aws_eks_addon" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-load-balancer-controller"
  addon_version            = var.aws_load_balancer_controller_version != "" ? var.aws_load_balancer_controller_version : null
  service_account_role_arn = var.enable_irsa ? aws_iam_role.aws_load_balancer_controller[0].arn : null
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-aws-lb-controller"
    }
  )

  depends_on = [
    aws_eks_node_group.this,
    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}
