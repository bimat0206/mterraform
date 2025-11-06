# AWS ECS (Elastic Container Service) Terraform Module

This module creates and manages AWS ECS clusters with Fargate support, task definitions, services, auto-scaling, and CloudWatch integration.

## Features

- **ECS Cluster**: Fully managed container orchestration with Container Insights
- **Fargate Support**: Serverless container execution (Fargate and Fargate Spot)
- **Task Definitions**: Flexible container definitions with multi-container support
- **ECS Services**: Managed service deployment with load balancer integration
- **Auto-scaling**: Target tracking and step scaling policies
- **IAM Roles**: Automatic creation of task execution and task roles
- **CloudWatch Logs**: Centralized logging for all containers
- **Load Balancer Integration**: ALB/NLB target group support
- **Service Discovery**: AWS Cloud Map integration
- **EFS Support**: Persistent storage with EFS volumes
- **ECS Exec**: Execute commands in running containers

## Usage

### Basic Fargate Service with ALB

```hcl
module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "api"

  # Cluster configuration
  enable_container_insights = true
  enable_fargate            = true

  # Task definition
  task_definitions = {
    web-app = {
      cpu    = "256"
      memory = "512"

      container_definitions = [
        {
          name  = "web"
          image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/myorg-prod-api-web:latest"

          portMappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]

          environment = [
            { name = "ENV", value = "production" },
            { name = "PORT", value = "8080" }
          ]

          healthCheck = {
            command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 60
          }
        }
      ]
    }
  }

  # ECS service
  services = {
    web-app = {
      task_definition_key = "web-app"
      desired_count       = 2

      subnets         = var.private_subnet_ids
      security_groups = [aws_security_group.ecs_tasks.id]

      load_balancers = [
        {
          target_group_arn = aws_lb_target_group.web.arn
          container_name   = "web"
          container_port   = 8080
        }
      ]

      health_check_grace_period_seconds = 60
    }
  }

  tags = {
    Project = "MyApp"
  }
}
```

### Multi-Container Task with Sidecar

```hcl
module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "microservices"

  task_definitions = {
    api-with-sidecar = {
      cpu    = "512"
      memory = "1024"

      container_definitions = [
        # Main application container
        {
          name  = "api"
          image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest"

          portMappings = [
            { containerPort = 3000 }
          ]

          environment = [
            { name = "NODE_ENV", value = "production" }
          ]

          secrets = [
            {
              name      = "DATABASE_URL"
              valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-url"
            }
          ]
        },
        # Logging sidecar
        {
          name      = "log-router"
          image     = "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest"
          essential = false

          environment = [
            { name = "FLB_LOG_LEVEL", value = "info" }
          ]
        }
      ]

      # Task role with application permissions
      task_role_policy_statements = [
        {
          effect = "Allow"
          actions = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          resources = ["arn:aws:s3:::my-bucket/*"]
        }
      ]
    }
  }

  services = {
    api = {
      task_definition_key = "api-with-sidecar"
      desired_count       = 3
      subnets             = var.private_subnet_ids
      security_groups     = [aws_security_group.api.id]
    }
  }
}
```

### Service with Auto-scaling

```hcl
module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "scalable-app"

  task_definitions = {
    backend = {
      cpu    = "256"
      memory = "512"

      container_definitions = [
        {
          name  = "app"
          image = "myapp:latest"
          portMappings = [{ containerPort = 8080 }]
        }
      ]
    }
  }

  services = {
    backend = {
      task_definition_key = "backend"
      desired_count       = 2

      subnets         = var.private_subnet_ids
      security_groups = [aws_security_group.app.id]

      load_balancers = [
        {
          target_group_arn = aws_lb_target_group.app.arn
          container_name   = "app"
          container_port   = 8080
        }
      ]

      # Auto-scaling configuration
      autoscaling = {
        min_capacity = 2
        max_capacity = 10

        target_tracking_policies = [
          {
            name               = "cpu-target-tracking"
            target_value       = 70.0
            predefined_metric  = "ECSServiceAverageCPUUtilization"
            scale_in_cooldown  = 300
            scale_out_cooldown = 60
          },
          {
            name               = "memory-target-tracking"
            target_value       = 80.0
            predefined_metric  = "ECSServiceAverageMemoryUtilization"
            scale_in_cooldown  = 300
            scale_out_cooldown = 60
          }
        ]
      }
    }
  }
}
```

### Fargate Spot for Cost Optimization

```hcl
module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "dev"
  workload    = "batch"

  enable_fargate      = true
  enable_fargate_spot = true

  # Use Fargate Spot for cost savings
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
      base              = 0
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1  # Always run at least 1 task on regular Fargate
    }
  ]

  task_definitions = {
    batch-worker = {
      cpu    = "1024"
      memory = "2048"

      container_definitions = [
        {
          name  = "worker"
          image = "batch-processor:latest"
        }
      ]
    }
  }

  services = {
    batch = {
      task_definition_key = "batch-worker"
      desired_count       = 5
      subnets             = var.private_subnet_ids
      security_groups     = [aws_security_group.batch.id]
    }
  }
}
```

### Task with EFS Volume

```hcl
module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "data-processing"

  task_definitions = {
    processor = {
      cpu    = "512"
      memory = "1024"

      container_definitions = [
        {
          name  = "processor"
          image = "data-processor:latest"

          mountPoints = [
            {
              sourceVolume  = "efs-storage"
              containerPath = "/mnt/efs"
              readOnly      = false
            }
          ]
        }
      ]

      # EFS volume
      volumes = [
        {
          name = "efs-storage"

          efs_volume_configuration = {
            file_system_id     = aws_efs_file_system.data.id
            root_directory     = "/data"
            transit_encryption = "ENABLED"

            authorization_config = {
              access_point_id = aws_efs_access_point.data.id
              iam             = "ENABLED"
            }
          }
        }
      ]
    }
  }

  services = {
    processor = {
      task_definition_key = "processor"
      desired_count       = 3
      subnets             = var.private_subnet_ids
      security_groups     = [aws_security_group.processor.id]
    }
  }
}
```

### Service Discovery with Cloud Map

```hcl
resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "internal.myapp.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "microservices"

  task_definitions = {
    backend = {
      cpu    = "256"
      memory = "512"

      container_definitions = [
        {
          name  = "api"
          image = "backend-api:latest"
          portMappings = [{ containerPort = 3000 }]
        }
      ]
    }
  }

  services = {
    backend = {
      task_definition_key  = "backend"
      desired_count        = 3
      subnets              = var.private_subnet_ids
      security_groups      = [aws_security_group.backend.id]
      service_registry_arn = aws_service_discovery_service.backend.arn
    }
  }
}
```

### Enable ECS Exec for Debugging

```hcl
module "ecs" {
  source = "./modules/ecs"

  org_prefix  = "myorg"
  environment = "dev"
  workload    = "debug-app"

  task_definitions = {
    app = {
      cpu    = "256"
      memory = "512"

      container_definitions = [
        {
          name  = "app"
          image = "myapp:latest"
        }
      ]
    }
  }

  services = {
    app = {
      task_definition_key    = "app"
      desired_count          = 1
      subnets                = var.private_subnet_ids
      security_groups        = [aws_security_group.app.id]
      enable_execute_command = true  # Enable ECS Exec
    }
  }
}

# Then use: aws ecs execute-command to access container
# aws ecs execute-command \
#   --cluster myorg-dev-debug-app \
#   --task <task-id> \
#   --container app \
#   --interactive \
#   --command "/bin/sh"
```

## Fargate Task Sizes

Valid CPU and memory combinations for Fargate:

| CPU (vCPU) | Memory (GB) |
|------------|-------------|
| 0.25       | 0.5, 1, 2   |
| 0.5        | 1, 2, 3, 4  |
| 1          | 2, 3, 4, 5, 6, 7, 8 |
| 2          | 4-16 (1 GB increments) |
| 4          | 8-30 (1 GB increments) |
| 8          | 16-60 (4 GB increments) |
| 16         | 32-120 (8 GB increments) |

## Container Insights

When `enable_container_insights = true`, the cluster provides:
- Performance monitoring dashboards
- Container-level metrics (CPU, memory, network, disk)
- Task and service-level metrics
- Automatic anomaly detection
- CloudWatch Logs integration

## Auto-scaling Strategies

### Target Tracking (Recommended)
Automatically adjusts capacity to maintain a target metric value:
- **ECSServiceAverageCPUUtilization**: Scale based on CPU (recommended: 70%)
- **ECSServiceAverageMemoryUtilization**: Scale based on memory (recommended: 80%)
- **ALBRequestCountPerTarget**: Scale based on ALB request count

### Step Scaling
More control over scaling behavior with step adjustments based on CloudWatch alarms.

## IAM Roles

### Task Execution Role
Required for ECS agent to:
- Pull images from ECR
- Write logs to CloudWatch
- Retrieve secrets from Secrets Manager
- Get parameters from SSM Parameter Store

### Task Role
Application-level permissions:
- Access to AWS services (S3, DynamoDB, SQS, etc.)
- Custom permissions per task definition

## Capacity Providers

### FARGATE
- Standard Fargate pricing
- Reliable capacity
- Use for production workloads

### FARGATE_SPOT
- Up to 70% cheaper than Fargate
- May be interrupted with 2-minute notice
- Use for fault-tolerant workloads (batch processing, dev/test)

## Load Balancer Integration

The module supports:
- **Application Load Balancer (ALB)**: HTTP/HTTPS traffic
- **Network Load Balancer (NLB)**: TCP/UDP traffic
- Multiple target groups per service
- Health check grace period configuration

## Deployment Strategies

### Rolling Update (Default)
```hcl
deployment_minimum_healthy_percent = 100
deployment_maximum_percent         = 200
```
Starts new tasks before stopping old ones (requires 2x capacity temporarily).

### Blue/Green
```hcl
deployment_minimum_healthy_percent = 50
deployment_maximum_percent         = 100
```
Replace half the tasks at a time (maintains capacity, slower deployment).

## Cost Optimization

1. **Use Fargate Spot** for non-critical workloads (70% savings)
2. **Right-size tasks** - Don't over-provision CPU/memory
3. **Use auto-scaling** to match demand
4. **Set log retention** to avoid unbounded CloudWatch costs
5. **Use ECR lifecycle policies** to reduce storage costs

### Fargate Pricing Example (us-east-1)
**Fargate**: 1 vCPU + 2 GB memory = ~$35/month (continuous)
**Fargate Spot**: 1 vCPU + 2 GB memory = ~$10.50/month (continuous)

## Best Practices

1. **Use health checks** for all web services
2. **Enable Container Insights** for production clusters
3. **Set appropriate auto-scaling** policies based on load patterns
4. **Use secrets** for sensitive data (not environment variables)
5. **Enable ECS Exec** only in non-production environments
6. **Use private subnets** for ECS tasks
7. **Implement graceful shutdown** in applications (handle SIGTERM)
8. **Set proper task roles** with least privilege
9. **Use immutable tags** for production images
10. **Monitor CloudWatch logs** retention to control costs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_prefix | Organization prefix | string | - | yes |
| environment | Environment name | string | - | yes |
| workload | Workload name | string | - | yes |
| cluster_name | Custom cluster name | string | "" | no |
| enable_container_insights | Enable Container Insights | bool | true | no |
| enable_fargate | Enable Fargate | bool | true | no |
| enable_fargate_spot | Enable Fargate Spot | bool | false | no |
| task_definitions | Task definition configurations | map(object) | {} | no |
| services | ECS service configurations | map(object) | {} | no |
| log_retention_in_days | CloudWatch log retention | number | 7 | no |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ECS cluster ID |
| cluster_arn | ECS cluster ARN |
| cluster_name | ECS cluster name |
| task_definition_arns | Task definition ARNs |
| service_ids | Service IDs |
| service_names | Service names |
| task_execution_role_arn | Task execution role ARN |
| log_group_names | CloudWatch log group names |
| summary | Configuration summary |
| commands | Useful AWS CLI commands |

## Examples

See `workload-account/terraform.tfvars.example` for comprehensive examples.

## File Organization

- **versions.tf**: Provider requirements
- **variables.tf**: Input variables
- **data.tf**: Data sources and locals
- **cluster.tf**: ECS cluster and capacity providers
- **iam_task_execution.tf**: Task execution role
- **iam_task_role.tf**: Task roles (per task definition)
- **task_definitions.tf**: Task definitions
- **services.tf**: ECS services
- **cloudwatch.tf**: CloudWatch log groups
- **autoscaling.tf**: Auto-scaling policies
- **outputs.tf**: Outputs
- **README.md**: This file
- **CHANGELOG.md**: Version history

## Notes

- Task definitions automatically get CloudWatch logging configured
- Service desired_count changes are ignored when autoscaling is enabled
- Task execution role includes Secrets Manager and SSM Parameter Store access
- ECS Exec requires additional IAM permissions and SSM Session Manager
- Fargate tasks require `awsvpc` network mode

## Limitations

- Maximum 10 containers per task definition
- Maximum 1000 tasks per service
- ECS Exec requires Session Manager plugin installed locally
- Fargate doesn't support privileged containers or custom CNI plugins
