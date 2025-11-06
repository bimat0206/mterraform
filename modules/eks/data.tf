# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "tls_certificate" "cluster" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# -----------------------------------------------------------------------------
# Locals for Naming Convention and OIDC
# -----------------------------------------------------------------------------
locals {
  # Service name defaults to 'eks' if not provided
  _service = coalesce(var.service, "eks")

  # Build name from tokens
  _tokens = compact([
    var.org_prefix,
    var.environment,
    var.workload,
    local._service,
    var.identifier
  ])

  # Create normalized name
  _raw = join("-", local._tokens)
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Control plane subnets
  control_plane_subnet_ids = length(var.control_plane_subnet_ids) > 0 ? var.control_plane_subnet_ids : var.subnet_ids

  # OIDC provider URL and ARN
  oidc_provider_url = var.enable_irsa ? replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "") : ""
  oidc_provider_arn = var.enable_irsa ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}" : ""

  # Tags
  common_tags = merge(
    var.tags,
    {
      Name        = local.name
      Environment = var.environment
      Workload    = var.workload
      Service     = "EKS"
      ManagedBy   = "Terraform"
    }
  )
}
