# -----------------------------------------------------------------------------
# Naming Convention Variables
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod, staging)"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., app, platform)"
}

variable "service" {
  type        = string
  default     = ""
  description = "Service name (e.g., api, web). If empty, will use 'eks'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# Cluster Configuration
# -----------------------------------------------------------------------------
variable "kubernetes_version" {
  type        = string
  default     = "1.28"
  description = "Kubernetes version to use for the EKS cluster"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public API server endpoint"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable private API server endpoint"
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks that can access the public API server endpoint"
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  default     = ""
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from"
}

variable "cluster_ip_family" {
  type        = string
  default     = "ipv4"
  description = "The IP family used to assign Kubernetes pod and service addresses (ipv4 or ipv6)"

  validation {
    condition     = contains(["ipv4", "ipv6"], var.cluster_ip_family)
    error_message = "Must be 'ipv4' or 'ipv6'"
  }
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster (minimum 2 subnets in different AZs)"
}

variable "control_plane_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs for the EKS control plane. If empty, will use subnet_ids"
}

# -----------------------------------------------------------------------------
# Control Plane Logging
# -----------------------------------------------------------------------------
variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "List of control plane logging types to enable"
}

variable "cluster_log_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs in CloudWatch"

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cluster_log_retention_days)
    error_message = "Must be a valid CloudWatch Logs retention value"
  }
}

# -----------------------------------------------------------------------------
# Node Group Configuration
# -----------------------------------------------------------------------------
variable "node_groups" {
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
  }))
  default     = {}
  description = "Map of node group configurations"
}

variable "node_security_group_additional_rules" {
  type = map(object({
    description              = string
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    source_security_group_id = optional(string, "")
  }))
  default     = {}
  description = "Additional security group rules for node groups"
}

# -----------------------------------------------------------------------------
# EKS Add-ons Configuration
# -----------------------------------------------------------------------------
variable "enable_vpc_cni_addon" {
  type        = bool
  default     = true
  description = "Enable Amazon VPC CNI add-on"
}

variable "vpc_cni_addon_version" {
  type        = string
  default     = ""
  description = "VPC CNI add-on version (leave empty for latest)"
}

variable "enable_coredns_addon" {
  type        = bool
  default     = true
  description = "Enable CoreDNS add-on"
}

variable "coredns_addon_version" {
  type        = string
  default     = ""
  description = "CoreDNS add-on version (leave empty for latest)"
}

variable "enable_kube_proxy_addon" {
  type        = bool
  default     = true
  description = "Enable kube-proxy add-on"
}

variable "kube_proxy_addon_version" {
  type        = string
  default     = ""
  description = "kube-proxy add-on version (leave empty for latest)"
}

variable "enable_ebs_csi_driver_addon" {
  type        = bool
  default     = true
  description = "Enable AWS EBS CSI Driver add-on"
}

variable "ebs_csi_driver_addon_version" {
  type        = string
  default     = ""
  description = "EBS CSI Driver add-on version (leave empty for latest)"
}

variable "enable_aws_load_balancer_controller" {
  type        = bool
  default     = true
  description = "Enable AWS Load Balancer Controller add-on"
}

variable "aws_load_balancer_controller_version" {
  type        = string
  default     = ""
  description = "AWS Load Balancer Controller version (leave empty for latest)"
}

# -----------------------------------------------------------------------------
# OIDC Provider Configuration
# -----------------------------------------------------------------------------
variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IAM Roles for Service Accounts (IRSA)"
}

# -----------------------------------------------------------------------------
# IAM Role Mapping Configuration
# -----------------------------------------------------------------------------
variable "aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "List of IAM roles to map to Kubernetes RBAC"
}

variable "aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "List of IAM users to map to Kubernetes RBAC"
}

variable "map_iam_groups" {
  type = map(object({
    iam_group_arn   = string
    k8s_groups      = list(string)
    k8s_username    = optional(string, "{{SessionName}}")
  }))
  default     = {}
  description = "Map of IAM groups to Kubernetes RBAC groups"
}

# -----------------------------------------------------------------------------
# Monitoring and Observability
# -----------------------------------------------------------------------------
variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Container Insights"
}

variable "container_insights_log_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain Container Insights logs"

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.container_insights_log_retention_days)
    error_message = "Must be a valid CloudWatch Logs retention value"
  }
}

# -----------------------------------------------------------------------------
# Encryption Configuration
# -----------------------------------------------------------------------------
variable "enable_cluster_encryption" {
  type        = bool
  default     = true
  description = "Enable encryption for Kubernetes secrets"
}

variable "cluster_encryption_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for cluster encryption (leave empty to create)"
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------
variable "cluster_security_group_additional_rules" {
  type = map(object({
    description              = string
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    source_security_group_id = optional(string, "")
  }))
  default     = {}
  description = "Additional security group rules for cluster"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources"
}
