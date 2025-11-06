# -----------------------------------------------------------------------------
# EKS Cluster Outputs
# -----------------------------------------------------------------------------
output "cluster_id" {
  description = "The ID/name of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = local.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster"
  value       = aws_eks_cluster.this.version
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = aws_eks_cluster.this.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.this.status
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

# -----------------------------------------------------------------------------
# OIDC Provider Outputs
# -----------------------------------------------------------------------------
output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = local.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider for EKS"
  value       = local.oidc_provider_url
}

# -----------------------------------------------------------------------------
# IAM Role Outputs
# -----------------------------------------------------------------------------
output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN of the EKS node groups"
  value       = aws_iam_role.node_group.arn
}

output "ebs_csi_driver_iam_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = var.enable_ebs_csi_driver_addon && var.enable_irsa ? aws_iam_role.ebs_csi_driver[0].arn : null
}

output "aws_load_balancer_controller_iam_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = var.enable_aws_load_balancer_controller && var.enable_irsa ? aws_iam_role.aws_load_balancer_controller[0].arn : null
}

output "container_insights_iam_role_arn" {
  description = "IAM role ARN for Container Insights"
  value       = var.enable_container_insights && var.enable_irsa ? aws_iam_role.container_insights[0].arn : null
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.node_group.id
}

# -----------------------------------------------------------------------------
# Node Group Outputs
# -----------------------------------------------------------------------------
output "node_group_ids" {
  description = "Map of node group IDs"
  value       = { for k, v in aws_eks_node_group.this : k => v.id }
}

output "node_group_arns" {
  description = "Map of node group ARNs"
  value       = { for k, v in aws_eks_node_group.this : k => v.arn }
}

output "node_group_status" {
  description = "Map of node group statuses"
  value       = { for k, v in aws_eks_node_group.this : k => v.status }
}

# -----------------------------------------------------------------------------
# Add-on Outputs
# -----------------------------------------------------------------------------
output "vpc_cni_addon_version" {
  description = "The version of the VPC CNI add-on"
  value       = var.enable_vpc_cni_addon ? aws_eks_addon.vpc_cni[0].addon_version : null
}

output "coredns_addon_version" {
  description = "The version of the CoreDNS add-on"
  value       = var.enable_coredns_addon ? aws_eks_addon.coredns[0].addon_version : null
}

output "kube_proxy_addon_version" {
  description = "The version of the kube-proxy add-on"
  value       = var.enable_kube_proxy_addon ? aws_eks_addon.kube_proxy[0].addon_version : null
}

output "ebs_csi_driver_addon_version" {
  description = "The version of the EBS CSI driver add-on"
  value       = var.enable_ebs_csi_driver_addon ? aws_eks_addon.ebs_csi_driver[0].addon_version : null
}

output "aws_load_balancer_controller_addon_version" {
  description = "The version of the AWS Load Balancer Controller add-on"
  value       = var.enable_aws_load_balancer_controller ? aws_eks_addon.aws_load_balancer_controller[0].addon_version : null
}

# -----------------------------------------------------------------------------
# CloudWatch Logs Outputs
# -----------------------------------------------------------------------------
output "cluster_log_group_name" {
  description = "Name of the CloudWatch log group for cluster logs"
  value       = length(var.enabled_cluster_log_types) > 0 ? aws_cloudwatch_log_group.cluster[0].name : null
}

output "cluster_log_group_arn" {
  description = "ARN of the CloudWatch log group for cluster logs"
  value       = length(var.enabled_cluster_log_types) > 0 ? aws_cloudwatch_log_group.cluster[0].arn : null
}

output "container_insights_log_group_names" {
  description = "Map of Container Insights log group names"
  value = var.enable_container_insights ? {
    application = aws_cloudwatch_log_group.container_insights[0].name
    performance = aws_cloudwatch_log_group.container_insights_performance[0].name
    dataplane   = aws_cloudwatch_log_group.container_insights_dataplane[0].name
  } : null
}

# -----------------------------------------------------------------------------
# Kubeconfig and Commands
# -----------------------------------------------------------------------------
output "kubeconfig_command" {
  description = "AWS CLI command to update kubeconfig"
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${local.name}"
}

output "kubectl_config" {
  description = "kubectl configuration for connecting to the cluster"
  value = {
    cluster_name                   = local.name
    endpoint                       = aws_eks_cluster.this.endpoint
    certificate_authority_data     = aws_eks_cluster.this.certificate_authority[0].data
    exec_api_version              = "client.authentication.k8s.io/v1beta1"
    exec_command                  = "aws"
    exec_args                     = ["eks", "get-token", "--cluster-name", local.name, "--region", data.aws_region.current.name]
  }
}

output "view_cluster_logs_command" {
  description = "AWS CLI command to view cluster logs"
  value       = length(var.enabled_cluster_log_types) > 0 ? "aws logs tail ${aws_cloudwatch_log_group.cluster[0].name} --follow --format short" : null
}

output "view_container_insights_command" {
  description = "AWS CLI command to view Container Insights logs"
  value       = var.enable_container_insights ? "aws logs tail /aws/containerinsights/${local.name}/application --follow --format short" : null
}

output "describe_cluster_command" {
  description = "AWS CLI command to describe the cluster"
  value       = "aws eks describe-cluster --name ${local.name} --region ${data.aws_region.current.name}"
}

output "list_addons_command" {
  description = "AWS CLI command to list add-ons"
  value       = "aws eks list-addons --cluster-name ${local.name} --region ${data.aws_region.current.name}"
}

output "list_node_groups_command" {
  description = "AWS CLI command to list node groups"
  value       = "aws eks list-nodegroups --cluster-name ${local.name} --region ${data.aws_region.current.name}"
}

# -----------------------------------------------------------------------------
# IAM Role Mapping Info
# -----------------------------------------------------------------------------
output "iam_role_mapping_info" {
  description = "Information about IAM role to Kubernetes RBAC mapping"
  value = {
    aws_auth_roles = var.aws_auth_roles
    aws_auth_users = var.aws_auth_users
    iam_groups     = var.map_iam_groups
  }
}

# -----------------------------------------------------------------------------
# Container Insights Setup Commands
# -----------------------------------------------------------------------------
output "container_insights_setup_commands" {
  description = "Commands to set up Container Insights"
  value = var.enable_container_insights ? {
    install_cloudwatch_observability = "aws eks create-addon --cluster-name ${local.name} --addon-name amazon-cloudwatch-observability --region ${data.aws_region.current.name}"
    verify_installation               = "kubectl get pods -n amazon-cloudwatch"
  } : null
}

# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------
output "enabled_log_types" {
  description = "List of enabled cluster log types"
  value       = var.enabled_cluster_log_types
}

output "cluster_logging_enabled" {
  description = "Whether cluster logging is enabled"
  value       = length(var.enabled_cluster_log_types) > 0
}

output "container_insights_enabled" {
  description = "Whether Container Insights is enabled"
  value       = var.enable_container_insights
}

# -----------------------------------------------------------------------------
# Add-ons Status
# -----------------------------------------------------------------------------
output "addons_enabled" {
  description = "Map of enabled add-ons"
  value = {
    vpc_cni                       = var.enable_vpc_cni_addon
    coredns                       = var.enable_coredns_addon
    kube_proxy                    = var.enable_kube_proxy_addon
    ebs_csi_driver                = var.enable_ebs_csi_driver_addon
    aws_load_balancer_controller  = var.enable_aws_load_balancer_controller
  }
}

# -----------------------------------------------------------------------------
# Fargate Profile Outputs
# -----------------------------------------------------------------------------
output "fargate_profile_ids" {
  description = "Map of Fargate profile IDs"
  value = {
    for k, v in aws_eks_fargate_profile.this : k => v.id
  }
}

output "fargate_profile_arns" {
  description = "Map of Fargate profile ARNs"
  value = {
    for k, v in aws_eks_fargate_profile.this : k => v.arn
  }
}

output "fargate_profile_status" {
  description = "Map of Fargate profile statuses"
  value = {
    for k, v in aws_eks_fargate_profile.this : k => v.status
  }
}

output "fargate_profile_role_arn" {
  description = "ARN of the Fargate profile IAM role"
  value       = length(var.fargate_profiles) > 0 ? aws_iam_role.fargate_profile[0].arn : null
}

output "fargate_profile_count" {
  description = "Number of Fargate profiles"
  value       = length(aws_eks_fargate_profile.this)
}

output "fargate_enabled" {
  description = "Whether Fargate profiles are enabled"
  value       = length(var.fargate_profiles) > 0
}
