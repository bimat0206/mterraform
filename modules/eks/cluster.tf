# -----------------------------------------------------------------------------
# KMS Key for Cluster Encryption
# -----------------------------------------------------------------------------
resource "aws_kms_key" "cluster" {
  count = var.enable_cluster_encryption && var.cluster_encryption_kms_key_id == "" ? 1 : 0

  description             = "KMS key for ${local.name} EKS cluster encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-encryption-key"
    }
  )
}

resource "aws_kms_alias" "cluster" {
  count = var.enable_cluster_encryption && var.cluster_encryption_kms_key_id == "" ? 1 : 0

  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.cluster[0].key_id
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = local.name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = local.control_plane_subnet_ids
    endpoint_public_access  = var.cluster_endpoint_public_access
    endpoint_private_access = var.cluster_endpoint_private_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  dynamic "encryption_config" {
    for_each = var.enable_cluster_encryption ? [1] : []
    content {
      provider {
        key_arn = var.cluster_encryption_kms_key_id != "" ? var.cluster_encryption_kms_key_id : aws_kms_key.cluster[0].arn
      }
      resources = ["secrets"]
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = var.cluster_service_ipv4_cidr != "" || var.cluster_ip_family != "ipv4" ? [1] : []
    content {
      service_ipv4_cidr = var.cluster_service_ipv4_cidr != "" ? var.cluster_service_ipv4_cidr : null
      ip_family         = var.cluster_ip_family
    }
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.cluster
  ]
}

# -----------------------------------------------------------------------------
# OIDC Provider for IRSA
# -----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.enable_irsa ? 1 : 0

  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-oidc-provider"
    }
  )
}
