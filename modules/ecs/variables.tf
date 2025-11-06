# Naming inputs
variable "org_prefix" {
  type        = string
  description = "Organization prefix for naming resources"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "workload" {
  type        = string
  description = "Workload or application name"
}

# Cluster Configuration
variable "cluster_name" {
  type        = string
  default     = ""
  description = "Custom cluster name (defaults to: {org_prefix}-{environment}-{workload})"
}

variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Container Insights for the cluster"
}

variable "cluster_settings" {
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

# Capacity Providers
variable "enable_fargate" {
  type        = bool
  default     = true
  description = "Enable AWS Fargate capacity provider"
}

variable "enable_fargate_spot" {
  type        = bool
  default     = false
  description = "Enable AWS Fargate Spot capacity provider"
}

variable "default_capacity_provider_strategy" {
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
  description = "Default capacity provider strategy for the cluster"
}

# Task Definitions
variable "task_definitions" {
  type = map(object({
    family                   = optional(string)
    cpu                      = string
    memory                   = string
    network_mode             = optional(string, "awsvpc")
    requires_compatibilities = optional(list(string), ["FARGATE"])

    # Container definitions
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

    # Task role (permissions for the application)
    task_role_arn = optional(string)
    task_role_policies = optional(list(string), [])
    task_role_policy_statements = optional(list(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    })), [])

    # Execution role (permissions for ECS agent)
    execution_role_arn = optional(string)

    # Volumes
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

    # Runtime platform
    runtime_platform = optional(object({
      operating_system_family = optional(string, "LINUX")
      cpu_architecture        = optional(string, "X86_64")
    }))

    # Tags
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of task definition configurations"
}

# ECS Services
variable "services" {
  type = map(object({
    task_definition_key = string
    desired_count       = number

    # Launch type
    launch_type = optional(string)
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = optional(number, 0)
    })))

    # Network configuration
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = optional(bool, false)

    # Load balancer configuration
    load_balancers = optional(list(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })), [])

    # Service discovery
    service_registry_arn = optional(string)

    # Deployment configuration
    deployment_minimum_healthy_percent = optional(number, 100)
    deployment_maximum_percent         = optional(number, 200)
    enable_ecs_managed_tags           = optional(bool, true)
    propagate_tags                    = optional(string, "SERVICE")
    enable_execute_command            = optional(bool, false)

    # Health check grace period
    health_check_grace_period_seconds = optional(number)

    # Placement constraints
    placement_constraints = optional(list(object({
      type       = string
      expression = optional(string)
    })), [])

    # Auto-scaling configuration
    autoscaling = optional(object({
      min_capacity = number
      max_capacity = number

      # Target tracking policies
      target_tracking_policies = optional(list(object({
        name               = string
        target_value       = number
        predefined_metric  = optional(string)  # ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization
        custom_metric      = optional(object({
          metric_name = string
          namespace   = string
          statistic   = string
        }))
        scale_in_cooldown  = optional(number, 300)
        scale_out_cooldown = optional(number, 60)
      })), [])

      # Step scaling policies
      step_scaling_policies = optional(list(object({
        name               = string
        adjustment_type    = string  # ChangeInCapacity, PercentChangeInCapacity, ExactCapacity
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

    # Tags
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of ECS service configurations"
}

# CloudWatch Logs
variable "create_cloudwatch_log_groups" {
  type        = bool
  default     = true
  description = "Create CloudWatch log groups for ECS tasks"
}

variable "log_retention_in_days" {
  type        = number
  default     = 7
  description = "Number of days to retain CloudWatch logs"
}

# Task Execution Role
variable "create_task_execution_role" {
  type        = bool
  default     = true
  description = "Create a default task execution role for all task definitions"
}

variable "task_execution_role_policies" {
  type        = list(string)
  default     = []
  description = "Additional IAM policies to attach to the task execution role"
}

# Common tags
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
}
