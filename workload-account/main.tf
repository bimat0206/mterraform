# -----------------------------------------------------------------------------
# Key Pair Module for Linux (optional)
# -----------------------------------------------------------------------------
module "keypair_linux" {
  count  = var.create_keypair_linux ? 1 : 0
  source = "../modules/keypair"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "linux"
  identifier  = "01"

  # Key Pair Configuration
  algorithm = var.keypair_algorithm
  rsa_bits  = var.keypair_rsa_bits

  # Secrets Manager Configuration
  create_secret                 = var.keypair_store_in_secretsmanager
  secret_recovery_window_in_days = var.keypair_secret_recovery_window
  secret_kms_key_id             = var.keypair_kms_key_id

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Key Pair Module for Windows (optional)
# -----------------------------------------------------------------------------
module "keypair_windows" {
  count  = var.create_keypair_windows ? 1 : 0
  source = "../modules/keypair"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "windows"
  identifier  = "01"

  # Key Pair Configuration
  algorithm = var.keypair_algorithm
  rsa_bits  = var.keypair_rsa_bits

  # Secrets Manager Configuration
  create_secret                 = var.keypair_store_in_secretsmanager
  secret_recovery_window_in_days = var.keypair_secret_recovery_window
  secret_kms_key_id             = var.keypair_kms_key_id

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Locals for Key Pair Names
# -----------------------------------------------------------------------------
locals {
  linux_key_name = var.create_keypair_linux ? module.keypair_linux[0].key_pair_name : (
    var.ec2_linux_existing_key_name != "" ? var.ec2_linux_existing_key_name : var.ec2_linux_key_name
  )

  windows_key_name = var.create_keypair_windows ? module.keypair_windows[0].key_pair_name : (
    var.ec2_windows_existing_key_name != "" ? var.ec2_windows_existing_key_name : var.ec2_windows_key_name
  )
}

# -----------------------------------------------------------------------------
# EC2 Linux Module (optional)
# -----------------------------------------------------------------------------
module "ec2_linux" {
  count  = var.ec2_linux_enabled ? 1 : 0
  source = "../modules/ec2-linux"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "app"
  identifier  = "01"

  # Network Configuration
  vpc_id                      = var.vpc_id
  subnet_id                   = var.ec2_linux_associate_public_ip ? var.public_subnet_ids[0] : var.private_subnet_ids[0]
  associate_public_ip_address = var.ec2_linux_associate_public_ip

  # Instance Configuration
  instance_type = var.ec2_linux_instance_type
  ami_id        = var.ec2_linux_ami_id
  key_name      = local.linux_key_name  # Use keypair module or existing/manual key
  monitoring    = var.ec2_linux_monitoring
  user_data     = var.ec2_linux_user_data

  # Storage Configuration
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = var.ec2_linux_root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  # IAM Configuration
  create_iam_instance_profile = var.ec2_linux_create_iam_profile
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  # Security Group Configuration
  create_security_group        = true
  security_group_ingress_rules = var.ec2_linux_security_group_ingress_rules

  # Tags
  tags = local.common_tags

  # Ensure key pair is created before EC2 instance
  depends_on = [module.keypair_linux]
}

# -----------------------------------------------------------------------------
# EC2 Windows Module (optional)
# -----------------------------------------------------------------------------
module "ec2_windows" {
  count  = var.ec2_windows_enabled ? 1 : 0
  source = "../modules/ec2-windows"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "app"
  identifier  = "01"

  # Network Configuration
  vpc_id                      = var.vpc_id
  subnet_id                   = var.ec2_windows_associate_public_ip ? var.public_subnet_ids[0] : var.private_subnet_ids[0]
  associate_public_ip_address = var.ec2_windows_associate_public_ip

  # Instance Configuration
  instance_type     = var.ec2_windows_instance_type
  ami_id            = var.ec2_windows_ami_id
  key_name          = local.windows_key_name  # Use keypair module or existing/manual key
  monitoring        = var.ec2_windows_monitoring
  user_data         = var.ec2_windows_user_data
  get_password_data = var.ec2_windows_get_password_data

  # Storage Configuration
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = var.ec2_windows_root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  # IAM Configuration
  create_iam_instance_profile = var.ec2_windows_create_iam_profile
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  # Security Group Configuration
  create_security_group        = true
  security_group_ingress_rules = var.ec2_windows_security_group_ingress_rules

  # Tags
  tags = local.common_tags

  # Ensure key pair is created before EC2 instance
  depends_on = [module.keypair_windows]
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL Module (optional)
# -----------------------------------------------------------------------------
module "rds_postgresql" {
  count  = var.rds_postgresql_enabled ? 1 : 0
  source = "../modules/rds-postgresql"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "db"
  identifier  = "01"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Database Configuration
  instance_class    = var.rds_postgresql_instance_class
  engine_version    = var.rds_postgresql_engine_version
  allocated_storage = var.rds_postgresql_allocated_storage
  database_name     = var.rds_postgresql_database_name
  master_username   = var.rds_postgresql_master_username

  # High Availability
  multi_az = var.rds_postgresql_multi_az

  # Backup
  backup_retention_period = var.rds_postgresql_backup_retention_period

  # Security
  create_security_group   = true
  allowed_cidr_blocks     = var.rds_postgresql_allowed_cidr_blocks
  deletion_protection     = var.rds_postgresql_deletion_protection

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  # Storage
  storage_encrypted = true

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# RDS MySQL Module (optional)
# -----------------------------------------------------------------------------
module "rds_mysql" {
  count  = var.rds_mysql_enabled ? 1 : 0
  source = "../modules/rds-mysql"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "db"
  identifier  = "01"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Database Configuration
  instance_class    = var.rds_mysql_instance_class
  engine_version    = var.rds_mysql_engine_version
  allocated_storage = var.rds_mysql_allocated_storage
  database_name     = var.rds_mysql_database_name
  master_username   = var.rds_mysql_master_username

  # High Availability
  multi_az = var.rds_mysql_multi_az

  # Backup
  backup_retention_period = var.rds_mysql_backup_retention_period

  # Security
  create_security_group   = true
  allowed_cidr_blocks     = var.rds_mysql_allowed_cidr_blocks
  deletion_protection     = var.rds_mysql_deletion_protection

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  # Storage
  storage_encrypted = true

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# RDS SQL Server Module (optional)
# -----------------------------------------------------------------------------
module "rds_sqlserver" {
  count  = var.rds_sqlserver_enabled ? 1 : 0
  source = "../modules/rds-sqlserver"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "db"
  identifier  = "02"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Database Configuration
  engine            = var.rds_sqlserver_engine
  engine_version    = var.rds_sqlserver_engine_version
  instance_class    = var.rds_sqlserver_instance_class
  allocated_storage = var.rds_sqlserver_allocated_storage
  database_name     = var.rds_sqlserver_database_name
  master_username   = var.rds_sqlserver_master_username

  # High Availability
  multi_az = var.rds_sqlserver_multi_az

  # Backup
  backup_retention_period = var.rds_sqlserver_backup_retention_period

  # Security
  create_security_group   = true
  allowed_cidr_blocks     = var.rds_sqlserver_allowed_cidr_blocks
  deletion_protection     = var.rds_sqlserver_deletion_protection

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  # Storage
  storage_encrypted = true

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# EKS Module (optional)
# -----------------------------------------------------------------------------
module "eks" {
  count  = var.eks_enabled ? 1 : 0
  source = "../modules/eks"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = var.eks_service_name
  identifier  = var.eks_identifier

  # Network Configuration
  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.eks_control_plane_subnet_ids

  # Cluster Configuration
  kubernetes_version               = var.eks_kubernetes_version
  cluster_endpoint_public_access   = var.eks_cluster_endpoint_public_access
  cluster_endpoint_private_access  = var.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.eks_cluster_endpoint_public_access_cidrs

  # Logging
  enabled_cluster_log_types  = var.eks_enabled_cluster_log_types
  cluster_log_retention_days = var.eks_cluster_log_retention_days

  # Encryption
  enable_cluster_encryption = var.eks_enable_cluster_encryption

  # Node Groups
  node_groups = var.eks_node_groups

  # Fargate Profiles
  fargate_profiles = var.eks_fargate_profiles

  # Add-ons
  enable_vpc_cni_addon                 = var.eks_enable_vpc_cni_addon
  enable_coredns_addon                 = var.eks_enable_coredns_addon
  enable_kube_proxy_addon              = var.eks_enable_kube_proxy_addon
  enable_ebs_csi_driver_addon          = var.eks_enable_ebs_csi_driver_addon
  enable_aws_load_balancer_controller  = var.eks_enable_aws_load_balancer_controller

  # IRSA
  enable_irsa = var.eks_enable_irsa

  # Container Insights
  enable_container_insights           = var.eks_enable_container_insights
  container_insights_log_retention_days = var.eks_container_insights_log_retention_days

  # IAM Mapping
  aws_auth_roles = var.eks_aws_auth_roles
  aws_auth_users = var.eks_aws_auth_users
  map_iam_groups = var.eks_map_iam_groups

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ECR Module (optional)
# -----------------------------------------------------------------------------
module "ecr" {
  count  = var.ecr_enabled ? 1 : 0
  source = "../modules/ecr"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload

  # ECR Repository Configuration
  repositories = var.ecr_repositories

  # Image Scanning
  enable_enhanced_scanning = var.ecr_enable_enhanced_scanning
  scan_frequency           = var.ecr_scan_frequency

  # Replication
  enable_replication        = var.ecr_enable_replication
  replication_configuration = var.ecr_replication_configuration

  # Pull Through Cache
  enable_pull_through_cache = var.ecr_enable_pull_through_cache
  pull_through_cache_rules  = var.ecr_pull_through_cache_rules

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ECS Module (optional)
# -----------------------------------------------------------------------------

# ECS Task Security Group
resource "aws_security_group" "ecs_tasks" {
  count = var.ecs_enabled ? 1 : 0

  name_prefix = "${local.naming.org_prefix}-${local.naming.environment}-${local.naming.workload}-ecs-tasks-"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Allow inbound from ALB security group (if ALB is enabled)
  dynamic "ingress" {
    for_each = var.ecs_alb_enabled ? [1] : []
    content {
      from_port       = 0
      to_port         = 65535
      protocol        = "tcp"
      security_groups = [aws_security_group.ecs_alb[0].id]
      description     = "Allow traffic from ALB"
    }
  }

  # Additional custom ingress rules
  dynamic "ingress" {
    for_each = var.ecs_additional_security_group_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      description = lookup(ingress.value, "description", "")
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.naming.org_prefix}-${local.naming.environment}-${local.naming.workload}-ecs-tasks"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group for ECS (optional)
resource "aws_security_group" "ecs_alb" {
  count = var.ecs_enabled && var.ecs_alb_enabled ? 1 : 0

  name_prefix = "${local.naming.org_prefix}-${local.naming.environment}-${local.naming.workload}-ecs-alb-"
  description = "Security group for ECS ALB"
  vpc_id      = var.vpc_id

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ecs_alb_ingress_cidrs
    description = "Allow HTTP from specified CIDRs"
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ecs_alb_ingress_cidrs
    description = "Allow HTTPS from specified CIDRs"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.naming.org_prefix}-${local.naming.environment}-${local.naming.workload}-ecs-alb"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer for ECS (optional)
resource "aws_lb" "ecs" {
  count = var.ecs_enabled && var.ecs_alb_enabled ? 1 : 0

  name               = "${local.naming.org_prefix}-${local.naming.environment}-${local.naming.workload}-ecs"
  internal           = var.ecs_alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb[0].id]
  subnets            = var.ecs_alb_internal ? var.private_subnet_ids : var.public_subnet_ids

  enable_deletion_protection = var.ecs_alb_enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.naming.org_prefix}-${local.naming.environment}-${local.naming.workload}-ecs"
    }
  )
}

# ALB Target Groups for ECS Services
resource "aws_lb_target_group" "ecs" {
  for_each = var.ecs_enabled && var.ecs_alb_enabled ? var.ecs_alb_target_groups : {}

  name     = "${local.naming.org_prefix}-${local.naming.environment}-${substr(each.key, 0, 20)}"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 3)
    timeout             = lookup(each.value.health_check, "timeout", 5)
    interval            = lookup(each.value.health_check, "interval", 30)
    path                = lookup(each.value.health_check, "path", "/health")
    matcher             = lookup(each.value.health_check, "matcher", "200")
    protocol            = each.value.protocol
  }

  deregistration_delay = lookup(each.value, "deregistration_delay", 30)

  tags = merge(
    local.common_tags,
    {
      Name = "${local.naming.org_prefix}-${local.naming.environment}-${each.key}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Listeners
resource "aws_lb_listener" "ecs_http" {
  count = var.ecs_enabled && var.ecs_alb_enabled ? 1 : 0

  load_balancer_arn = aws_lb.ecs[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.ecs_alb_redirect_http_to_https ? "redirect" : "fixed-response"

    dynamic "redirect" {
      for_each = var.ecs_alb_redirect_http_to_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "fixed_response" {
      for_each = var.ecs_alb_redirect_http_to_https ? [] : [1]
      content {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }
}

# ALB Listener Rules for routing to target groups
resource "aws_lb_listener_rule" "ecs" {
  for_each = var.ecs_enabled && var.ecs_alb_enabled ? var.ecs_alb_listener_rules : {}

  listener_arn = aws_lb_listener.ecs_http[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs[each.value.target_group_key].arn
  }

  dynamic "condition" {
    for_each = lookup(each.value, "path_pattern", null) != null ? [1] : []
    content {
      path_pattern {
        values = [each.value.path_pattern]
      }
    }
  }

  dynamic "condition" {
    for_each = lookup(each.value, "host_header", null) != null ? [1] : []
    content {
      host_header {
        values = [each.value.host_header]
      }
    }
  }
}

# Build ECS task definitions with dynamic ECR image references
locals {
  # Build task definitions with ECR repository URLs if ECR is enabled
  ecs_task_definitions_with_ecr = var.ecs_enabled && var.ecr_enabled ? {
    for task_key, task_def in var.ecs_task_definitions : task_key => merge(
      task_def,
      {
        container_definitions = [
          for container in task_def.container_definitions : merge(
            container,
            {
              # Replace image placeholder with actual ECR URL if it references ECR
              image = can(regex("^ecr://(.+)", container.image)) ?
                "${module.ecr[0].repository_urls[regex("^ecr://(.+)", container.image)[0]]}:${lookup(container, "image_tag", "latest")}" :
                container.image
            }
          )
        ]
      }
    )
  } : var.ecs_task_definitions

  # Build ECS services with dynamic references
  ecs_services_with_references = var.ecs_enabled ? {
    for svc_key, svc in var.ecs_services : svc_key => merge(
      svc,
      {
        # Use dynamically created security group
        security_groups = [aws_security_group.ecs_tasks[0].id]

        # Use private subnets by default
        subnets = var.private_subnet_ids

        # Add load balancer configuration if ALB is enabled
        load_balancers = var.ecs_alb_enabled && lookup(svc, "target_group_key", null) != null ? [
          {
            target_group_arn = aws_lb_target_group.ecs[svc.target_group_key].arn
            container_name   = svc.container_name
            container_port   = svc.container_port
          }
        ] : lookup(svc, "load_balancers", [])
      }
    )
  } : {}
}

module "ecs" {
  count  = var.ecs_enabled ? 1 : 0
  source = "../modules/ecs"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload

  # Cluster Configuration
  cluster_name              = var.ecs_cluster_name
  enable_container_insights = var.ecs_enable_container_insights
  cluster_settings          = var.ecs_cluster_settings

  # Capacity Providers
  enable_fargate                     = var.ecs_enable_fargate
  enable_fargate_spot                = var.ecs_enable_fargate_spot
  default_capacity_provider_strategy = var.ecs_default_capacity_provider_strategy

  # Task Definitions with dynamic ECR references
  task_definitions = local.ecs_task_definitions_with_ecr

  # Services with dynamic security groups and subnets
  services = local.ecs_services_with_references

  # CloudWatch Logs
  create_cloudwatch_log_groups = var.ecs_create_cloudwatch_log_groups
  log_retention_in_days        = var.ecs_log_retention_in_days

  # Task Execution Role
  create_task_execution_role   = var.ecs_create_task_execution_role
  task_execution_role_policies = var.ecs_task_execution_role_policies

  # Tags
  tags = local.common_tags

  # Ensure ECR is created before ECS
  depends_on = [module.ecr]
}
