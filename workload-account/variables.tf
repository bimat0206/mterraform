# -----------------------------------------------------------------------------
# General configuration
# -----------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS region where resources will be created"
}

# -----------------------------------------------------------------------------
# Naming convention inputs
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming (e.g., 'tsk')"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'prod', 'staging')"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., 'app', 'platform')"
}

# -----------------------------------------------------------------------------
# Tagging
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# Network Configuration (from Network Account)
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID from network account (use remote state or data source)"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs from network account"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs from network account"
}

# -----------------------------------------------------------------------------
# Key Pair Configuration
# -----------------------------------------------------------------------------
variable "create_keypair_linux" {
  type        = bool
  default     = false
  description = "Create EC2 key pair for Linux instances"
}

variable "create_keypair_windows" {
  type        = bool
  default     = false
  description = "Create EC2 key pair for Windows instances"
}

variable "keypair_algorithm" {
  type        = string
  default     = "RSA"
  description = "Algorithm for key pair generation (RSA, ECDSA, ED25519)"
}

variable "keypair_rsa_bits" {
  type        = number
  default     = 4096
  description = "RSA key size (2048 or 4096)"
}

variable "keypair_store_in_secretsmanager" {
  type        = bool
  default     = true
  description = "Store private keys in AWS Secrets Manager"
}

variable "keypair_secret_recovery_window" {
  type        = number
  default     = 30
  description = "Recovery window for deleted secrets (7-30 days)"
}

variable "keypair_kms_key_id" {
  type        = string
  default     = ""
  description = "Custom KMS key ID for secret encryption (empty = AWS managed key)"
}

# Use existing key pair names instead of creating new ones
variable "ec2_linux_existing_key_name" {
  type        = string
  default     = ""
  description = "Existing key pair name for Linux instance (if not creating new keypair)"
}

variable "ec2_windows_existing_key_name" {
  type        = string
  default     = ""
  description = "Existing key pair name for Windows instance (if not creating new keypair)"
}

# -----------------------------------------------------------------------------
# EC2 Linux Configuration
# -----------------------------------------------------------------------------
variable "ec2_linux_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Linux EC2 instance"
}

variable "ec2_linux_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance type for Linux EC2"
}

variable "ec2_linux_ami_id" {
  type        = string
  default     = ""
  description = "AMI ID for Linux (empty = auto-discover Amazon Linux 2023)"
}

variable "ec2_linux_key_name" {
  type        = string
  default     = ""
  description = "EC2 key pair name for SSH access to Linux instance"
}

variable "ec2_linux_associate_public_ip" {
  type        = bool
  default     = false
  description = "Associate public IP with Linux instance"
}

variable "ec2_linux_user_data" {
  type        = string
  default     = ""
  description = "User data script for Linux instance"
}

variable "ec2_linux_create_iam_profile" {
  type        = bool
  default     = true
  description = "Create IAM instance profile for Linux instance"
}

variable "ec2_linux_security_group_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH from VPC"
    }
  ]
  description = "Security group ingress rules for Linux instance"
}

variable "ec2_linux_root_volume_size" {
  type        = number
  default     = 20
  description = "Root volume size in GB for Linux instance"
}

variable "ec2_linux_monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed monitoring for Linux instance"
}

# -----------------------------------------------------------------------------
# EC2 Windows Configuration
# -----------------------------------------------------------------------------
variable "ec2_windows_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Windows EC2 instance"
}

variable "ec2_windows_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for Windows EC2 (minimum t3.medium recommended)"
}

variable "ec2_windows_ami_id" {
  type        = string
  default     = ""
  description = "AMI ID for Windows (empty = auto-discover Windows Server 2022)"
}

variable "ec2_windows_key_name" {
  type        = string
  default     = ""
  description = "EC2 key pair name for Windows instance (for password retrieval)"
}

variable "ec2_windows_associate_public_ip" {
  type        = bool
  default     = false
  description = "Associate public IP with Windows instance"
}

variable "ec2_windows_get_password_data" {
  type        = bool
  default     = false
  description = "Retrieve Windows administrator password"
}

variable "ec2_windows_user_data" {
  type        = string
  default     = ""
  description = "User data PowerShell script for Windows instance"
}

variable "ec2_windows_create_iam_profile" {
  type        = bool
  default     = true
  description = "Create IAM instance profile for Windows instance"
}

variable "ec2_windows_security_group_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "RDP from VPC"
    },
    {
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "WinRM from VPC"
    }
  ]
  description = "Security group ingress rules for Windows instance"
}

variable "ec2_windows_root_volume_size" {
  type        = number
  default     = 50
  description = "Root volume size in GB for Windows instance"
}

variable "ec2_windows_monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed monitoring for Windows instance"
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL Configuration
# -----------------------------------------------------------------------------
variable "rds_postgresql_enabled" {
  type        = bool
  default     = false
  description = "Whether to create PostgreSQL RDS instance"
}

variable "rds_postgresql_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class for PostgreSQL RDS"
}

variable "rds_postgresql_engine_version" {
  type        = string
  default     = "16.1"
  description = "PostgreSQL engine version"
}

variable "rds_postgresql_allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB for PostgreSQL"
}

variable "rds_postgresql_database_name" {
  type        = string
  default     = ""
  description = "Initial database name for PostgreSQL"
}

variable "rds_postgresql_master_username" {
  type        = string
  default     = "postgres"
  description = "Master username for PostgreSQL"
}

variable "rds_postgresql_multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ for PostgreSQL"
}

variable "rds_postgresql_backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days for PostgreSQL"
}

variable "rds_postgresql_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to access PostgreSQL RDS"
}

variable "rds_postgresql_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection for PostgreSQL"
}

# -----------------------------------------------------------------------------
# RDS MySQL Configuration
# -----------------------------------------------------------------------------
variable "rds_mysql_enabled" {
  type        = bool
  default     = false
  description = "Whether to create MySQL RDS instance"
}

variable "rds_mysql_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance class for MySQL RDS"
}

variable "rds_mysql_engine_version" {
  type        = string
  default     = "8.0.35"
  description = "MySQL engine version"
}

variable "rds_mysql_allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB for MySQL"
}

variable "rds_mysql_database_name" {
  type        = string
  default     = ""
  description = "Initial database name for MySQL"
}

variable "rds_mysql_master_username" {
  type        = string
  default     = "admin"
  description = "Master username for MySQL"
}

variable "rds_mysql_multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ for MySQL"
}

variable "rds_mysql_backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days for MySQL"
}

variable "rds_mysql_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to access MySQL RDS"
}

variable "rds_mysql_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection for MySQL"
}

# -----------------------------------------------------------------------------
# RDS SQL Server Configuration
# -----------------------------------------------------------------------------
variable "rds_sqlserver_enabled" {
  type        = bool
  default     = false
  description = "Enable SQL Server RDS instance"
}

variable "rds_sqlserver_engine" {
  type        = string
  default     = "sqlserver-se"
  description = "SQL Server engine type (sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web)"
}

variable "rds_sqlserver_instance_class" {
  type        = string
  default     = "db.t3.xlarge"
  description = "Instance class for SQL Server RDS (minimum db.t3.xlarge for Standard/Enterprise)"
}

variable "rds_sqlserver_engine_version" {
  type        = string
  default     = "15.00.4335.1.v1"
  description = "SQL Server engine version (15.00 for SQL Server 2019, 16.00 for SQL Server 2022)"
}

variable "rds_sqlserver_allocated_storage" {
  type        = number
  default     = 100
  description = "Allocated storage in GB for SQL Server"
}

variable "rds_sqlserver_database_name" {
  type        = string
  default     = ""
  description = "Initial database name for SQL Server (optional)"
}

variable "rds_sqlserver_master_username" {
  type        = string
  default     = "sqladmin"
  description = "Master username for SQL Server (cannot be admin, administrator, sa, or root)"
}

variable "rds_sqlserver_multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ for SQL Server (not supported for Express/Web editions)"
}

variable "rds_sqlserver_backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days for SQL Server"
}

variable "rds_sqlserver_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to access SQL Server RDS"
}

variable "rds_sqlserver_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection for SQL Server"
}

# -----------------------------------------------------------------------------
# EKS Variables
# -----------------------------------------------------------------------------
variable "eks_enabled" {
  type        = bool
  default     = false
  description = "Enable EKS cluster deployment"
}

variable "eks_service_name" {
  type        = string
  default     = "eks"
  description = "Service name for EKS cluster"
}

variable "eks_identifier" {
  type        = string
  default     = "01"
  description = "Identifier for EKS cluster"
}

variable "eks_control_plane_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs for EKS control plane (if empty, uses private_subnet_ids)"
}

variable "eks_kubernetes_version" {
  type        = string
  default     = "1.28"
  description = "Kubernetes version for EKS cluster"
}

variable "eks_cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public access to EKS API endpoint"
}

variable "eks_cluster_endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable private access to EKS API endpoint"
}

variable "eks_cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to access public EKS API endpoint"
}

variable "eks_enabled_cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "EKS control plane log types to enable"
}

variable "eks_cluster_log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention days for EKS control plane logs"
}

variable "eks_enable_cluster_encryption" {
  type        = bool
  default     = true
  description = "Enable KMS encryption for Kubernetes secrets"
}

variable "eks_node_groups" {
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    general = {
      instance_types = ["t3.xlarge"]
      desired_size   = 2
      min_size       = 1
      max_size       = 4
      capacity_type  = "ON_DEMAND"
      disk_size      = 50
      labels         = {}
      taints         = []
    }
  }
  description = "EKS node group configurations"
}

variable "eks_fargate_profiles" {
  type = map(object({
    subnet_ids = list(string)
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "EKS Fargate profile configurations"
}

variable "eks_enable_vpc_cni_addon" {
  type        = bool
  default     = true
  description = "Enable VPC CNI add-on"
}

variable "eks_enable_coredns_addon" {
  type        = bool
  default     = true
  description = "Enable CoreDNS add-on"
}

variable "eks_enable_kube_proxy_addon" {
  type        = bool
  default     = true
  description = "Enable kube-proxy add-on"
}

variable "eks_enable_ebs_csi_driver_addon" {
  type        = bool
  default     = true
  description = "Enable EBS CSI driver add-on"
}

variable "eks_enable_aws_load_balancer_controller" {
  type        = bool
  default     = true
  description = "Enable AWS Load Balancer Controller add-on"
}

variable "eks_enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IAM Roles for Service Accounts (IRSA)"
}

variable "eks_enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Container Insights"
}

variable "eks_container_insights_log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention days for Container Insights"
}

variable "eks_aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "IAM roles to map to Kubernetes RBAC"
}

variable "eks_aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "IAM users to map to Kubernetes RBAC"
}

variable "eks_map_iam_groups" {
  type = map(object({
    iam_group_arn   = string
    k8s_groups      = list(string)
    k8s_username    = optional(string, "{{SessionName}}")
  }))
  default     = {}
  description = "IAM groups to map to Kubernetes RBAC"
}

# -----------------------------------------------------------------------------
# ECR Module Variables
# -----------------------------------------------------------------------------
variable "ecr_enabled" {
  type        = bool
  default     = false
  description = "Enable ECR module"
}

variable "ecr_repositories" {
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")
    kms_key_arn          = optional(string, null)

    lifecycle_policy = optional(object({
      max_image_count        = optional(number, 30)
      max_untagged_days      = optional(number, 7)
      max_tagged_days        = optional(number, 90)
      protected_tags         = optional(list(string), ["latest", "prod", "production"])
      enable_untagged_expiry = optional(bool, true)
    }), {})

    repository_policy = optional(string, null)
    force_delete      = optional(bool, false)
    tags              = optional(map(string), {})
  }))
  default     = {}
  description = "ECR repository configurations"
}

variable "ecr_enable_enhanced_scanning" {
  type        = bool
  default     = false
  description = "Enable AWS Inspector enhanced scanning"
}

variable "ecr_scan_frequency" {
  type        = string
  default     = "SCAN_ON_PUSH"
  description = "Scan frequency: SCAN_ON_PUSH, CONTINUOUS_SCAN, or MANUAL"
}

variable "ecr_enable_replication" {
  type        = bool
  default     = false
  description = "Enable cross-region or cross-account replication"
}

variable "ecr_replication_configuration" {
  type = object({
    rules = list(object({
      destinations = list(object({
        region      = string
        registry_id = optional(string)
      }))
      repository_filters = optional(list(object({
        filter      = string
        filter_type = string
      })), [])
    }))
  })
  default = {
    rules = []
  }
  description = "Replication configuration for ECR"
}

variable "ecr_enable_pull_through_cache" {
  type        = bool
  default     = false
  description = "Enable pull through cache for public registries"
}

variable "ecr_pull_through_cache_rules" {
  type = map(object({
    upstream_registry_url = string
    credential_arn        = optional(string)
  }))
  default     = {}
  description = "Pull through cache rules"
}

# -----------------------------------------------------------------------------
# ECS Module Variables
# -----------------------------------------------------------------------------
variable "ecs_enabled" {
  type        = bool
  default     = false
  description = "Enable ECS module"
}

variable "ecs_cluster_name" {
  type        = string
  default     = ""
  description = "Custom ECS cluster name (defaults to: org-env-workload)"
}

variable "ecs_enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Container Insights"
}

variable "ecs_cluster_settings" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
  description = "ECS cluster settings"
}

variable "ecs_enable_fargate" {
  type        = bool
  default     = true
  description = "Enable AWS Fargate capacity provider"
}

variable "ecs_enable_fargate_spot" {
  type        = bool
  default     = false
  description = "Enable AWS Fargate Spot capacity provider"
}

variable "ecs_default_capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
  description = "Default capacity provider strategy"
}

variable "ecs_task_definitions" {
  type = map(object({
    family                   = optional(string)
    cpu                      = string
    memory                   = string
    network_mode             = optional(string, "awsvpc")
    requires_compatibilities = optional(list(string), ["FARGATE"])

    container_definitions = list(object({
      name         = string
      image        = string
      cpu          = optional(number)
      memory       = optional(number)
      essential    = optional(bool, true)
      command      = optional(list(string))
      entryPoint   = optional(list(string))
      environment  = optional(list(object({
        name  = string
        value = string
      })), [])
      secrets      = optional(list(object({
        name      = string
        valueFrom = string
      })), [])
      portMappings = optional(list(object({
        containerPort = number
        hostPort      = optional(number)
        protocol      = optional(string, "tcp")
      })), [])
      healthCheck  = optional(object({
        command     = list(string)
        interval    = optional(number, 30)
        timeout     = optional(number, 5)
        retries     = optional(number, 3)
        startPeriod = optional(number, 0)
      }))
      logConfiguration = optional(object({
        logDriver = string
        options   = map(string)
      }))
      mountPoints = optional(list(object({
        sourceVolume  = string
        containerPath = string
        readOnly      = optional(bool, false)
      })), [])
      volumesFrom = optional(list(object({
        sourceContainer = string
        readOnly        = optional(bool, false)
      })), [])
    }))

    task_role_arn = optional(string)
    task_role_policies = optional(list(string), [])
    task_role_policy_statements = optional(list(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    })), [])

    execution_role_arn = optional(string)

    volumes = optional(list(object({
      name      = string
      host_path = optional(string)
      efs_volume_configuration = optional(object({
        file_system_id          = string
        root_directory          = optional(string, "/")
        transit_encryption      = optional(string, "ENABLED")
        transit_encryption_port = optional(number)
        authorization_config = optional(object({
          access_point_id = optional(string)
          iam             = optional(string, "DISABLED")
        }))
      }))
    })), [])

    runtime_platform = optional(object({
      operating_system_family = optional(string, "LINUX")
      cpu_architecture        = optional(string, "X86_64")
    }))

    tags = optional(map(string), {})
  }))
  default     = {}
  description = "ECS task definition configurations"
}

variable "ecs_services" {
  type = map(object({
    task_definition_key = string
    desired_count       = number

    launch_type = optional(string)
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = optional(number, 0)
    })))

    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = optional(bool, false)

    load_balancers = optional(list(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })), [])

    service_registry_arn = optional(string)

    deployment_minimum_healthy_percent = optional(number, 100)
    deployment_maximum_percent         = optional(number, 200)
    enable_ecs_managed_tags           = optional(bool, true)
    propagate_tags                    = optional(string, "SERVICE")
    enable_execute_command            = optional(bool, false)

    health_check_grace_period_seconds = optional(number)

    placement_constraints = optional(list(object({
      type       = string
      expression = optional(string)
    })), [])

    autoscaling = optional(object({
      min_capacity = number
      max_capacity = number

      target_tracking_policies = optional(list(object({
        name               = string
        target_value       = number
        predefined_metric  = optional(string)
        custom_metric      = optional(object({
          metric_name = string
          namespace   = string
          statistic   = string
        }))
        scale_in_cooldown  = optional(number, 300)
        scale_out_cooldown = optional(number, 60)
      })), [])

      step_scaling_policies = optional(list(object({
        name               = string
        adjustment_type    = string
        cooldown           = optional(number, 300)
        metric_aggregation_type = optional(string, "Average")

        step_adjustments = list(object({
          scaling_adjustment          = number
          metric_interval_lower_bound = optional(number)
          metric_interval_upper_bound = optional(number)
        }))

        alarm_name = string
      })), [])
    }))

    tags = optional(map(string), {})
  }))
  default     = {}
  description = "ECS service configurations"
}

variable "ecs_create_cloudwatch_log_groups" {
  type        = bool
  default     = true
  description = "Create CloudWatch log groups for ECS tasks"
}

variable "ecs_log_retention_in_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention days"
}

variable "ecs_create_task_execution_role" {
  type        = bool
  default     = true
  description = "Create task execution role"
}

variable "ecs_task_execution_role_policies" {
  type        = list(string)
  default     = []
  description = "Additional IAM policies for task execution role"
}
