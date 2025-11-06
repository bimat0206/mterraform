# Changelog

All notable changes to the ECS module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of ECS module with comprehensive features
- ECS cluster creation with customizable name
- Container Insights support for monitoring and observability
- Capacity provider support:
  - AWS Fargate (serverless)
  - AWS Fargate Spot (up to 70% cost savings)
  - Configurable default capacity provider strategy
- Task definition support:
  - Multi-container task definitions
  - Flexible CPU and memory configurations (Fargate task sizes)
  - Container-level configuration (environment, secrets, port mappings)
  - Health checks for containers
  - Custom log configuration or automatic CloudWatch Logs
  - EFS volume support with transit encryption
  - Runtime platform configuration (OS, CPU architecture)
  - Host path volumes
- IAM role management:
  - Automatic task execution role creation with full permissions
  - Per-task-definition task roles with custom policies
  - Secrets Manager and SSM Parameter Store access
  - KMS decryption permissions
- ECS service deployment:
  - Fargate and Fargate Spot launch types
  - Network configuration (subnets, security groups, public IP)
  - Application Load Balancer integration
  - Network Load Balancer support
  - Service discovery with AWS Cloud Map
  - Deployment configuration (min/max healthy percent)
  - ECS managed tags and tag propagation
  - ECS Exec support for debugging
  - Health check grace period
  - Placement constraints
- Auto-scaling support:
  - Target tracking scaling policies (CPU, memory, ALB request count)
  - Step scaling policies with CloudWatch alarms
  - Configurable min/max capacity
  - Scale-in and scale-out cooldown periods
- CloudWatch Logs integration:
  - Automatic log group creation per task definition
  - Configurable log retention (default: 7 days)
  - Per-container log streams
- Comprehensive outputs for integration and monitoring

### File Organization
- **versions.tf**: Provider requirements (Terraform >= 1.6.0, AWS ~> 5.0)
- **variables.tf**: 15+ input variables for comprehensive configuration
- **data.tf**: Data sources and local values
- **cluster.tf**: ECS cluster and capacity provider resources
- **iam_task_execution.tf**: Task execution role with full permissions
- **iam_task_role.tf**: Per-task-definition IAM roles
- **task_definitions.tf**: Task definition resources with container definitions
- **services.tf**: ECS service resources with load balancer integration
- **cloudwatch.tf**: CloudWatch log group resources
- **autoscaling.tf**: Auto-scaling target and policy resources
- **outputs.tf**: 20+ outputs including ARNs, names, and helpful commands
- **README.md**: Comprehensive documentation with examples
- **CHANGELOG.md**: This file

### Outputs
- Cluster information (ID, ARN, name, capacity providers)
- Task definition information (ARNs, families, revisions)
- Service information (IDs, names, cluster ARNs, desired counts)
- IAM role information (task execution role, task roles)
- CloudWatch log group information
- Auto-scaling information
- Configuration summary
- Useful AWS CLI commands (list services, list tasks, view logs, execute command)

### Features Summary
- **Serverless Container Execution**: Fargate eliminates need to manage EC2 instances
- **Cost Optimization**: Fargate Spot for up to 70% savings
- **Production Ready**: Container Insights, auto-scaling, health checks
- **Secure**: IAM roles with least privilege, secrets management
- **Observable**: CloudWatch Logs integration, Container Insights
- **Flexible**: Multi-container support, EFS volumes, service discovery
- **Easy Debugging**: ECS Exec support for interactive shell access
- **Scalable**: Auto-scaling based on CPU, memory, or custom metrics

### Default Values
- Cluster name: `{org_prefix}-{environment}-{workload}`
- Container Insights: `enabled`
- Fargate: `enabled`
- Fargate Spot: `disabled`
- Network mode: `awsvpc`
- Task compatibility: `["FARGATE"]`
- Deployment minimum healthy percent: `100`
- Deployment maximum percent: `200`
- ECS managed tags: `enabled`
- Tag propagation: `SERVICE`
- ECS Exec: `disabled`
- Assign public IP: `false`
- Log retention: `7 days`
- Create CloudWatch log groups: `true`
- Create task execution role: `true`

### Capacity Provider Strategies

#### Fargate Only (Default)
```hcl
default_capacity_provider_strategy = [
  {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
]
```

#### Mixed Fargate and Fargate Spot
```hcl
default_capacity_provider_strategy = [
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4
    base              = 0
  },
  {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
]
```

### Fargate Task Sizes
Supported CPU and memory combinations:
- 0.25 vCPU: 0.5-2 GB memory
- 0.5 vCPU: 1-4 GB memory
- 1 vCPU: 2-8 GB memory
- 2 vCPU: 4-16 GB memory
- 4 vCPU: 8-30 GB memory
- 8 vCPU: 16-60 GB memory
- 16 vCPU: 32-120 GB memory

### Auto-scaling Metrics

#### Target Tracking (Recommended)
- **ECSServiceAverageCPUUtilization**: Maintain target CPU utilization
- **ECSServiceAverageMemoryUtilization**: Maintain target memory utilization
- **ALBRequestCountPerTarget**: Scale based on request volume

#### Step Scaling
Custom CloudWatch alarm-based scaling with step adjustments.

### Container Insights Benefits
- Real-time container performance metrics
- Task and service-level visibility
- Network and disk I/O metrics
- Automatic dashboards in CloudWatch
- Anomaly detection
- No additional configuration required

### Load Balancer Integration
- **ALB**: HTTP/HTTPS with path-based routing
- **NLB**: TCP/UDP with connection-based routing
- Multiple target groups per service
- Health check grace period support
- Automatic target registration

### EFS Volume Support
- Persistent storage across tasks
- Shared storage between containers
- Transit encryption enabled
- EFS Access Point support
- IAM authorization support

### IAM Permissions

#### Task Execution Role (ECS Agent)
- Pull images from ECR
- Write logs to CloudWatch Logs
- Retrieve secrets from Secrets Manager
- Get parameters from SSM Parameter Store
- Decrypt with KMS

#### Task Role (Application)
- Custom permissions per task definition
- AWS managed policies
- Inline policy statements
- S3, DynamoDB, SQS, SNS access as needed

### Deployment Strategies

#### Rolling Update (Default)
- `deployment_minimum_healthy_percent = 100`
- `deployment_maximum_percent = 200`
- Zero downtime, requires 2x capacity temporarily

#### Blue/Green
- `deployment_minimum_healthy_percent = 50`
- `deployment_maximum_percent = 100`
- Replace half at a time, maintains capacity

### Cost Considerations

#### Fargate Pricing (us-east-1)
- **CPU**: $0.04048 per vCPU per hour
- **Memory**: $0.004445 per GB per hour
- **Example**: 1 vCPU + 2 GB = ~$35/month

#### Fargate Spot Pricing (us-east-1)
- **Up to 70% discount** vs regular Fargate
- **Example**: 1 vCPU + 2 GB = ~$10.50/month
- May be interrupted with 2-minute warning

#### Other Costs
- **CloudWatch Logs**: $0.50 per GB ingested
- **Container Insights**: Included (no additional charge)
- **Data Transfer**: Standard AWS rates
- **Load Balancer**: ALB/NLB charges apply

### Best Practices Implemented
- Automatic CloudWatch Logs configuration
- Task execution role with Secrets Manager access
- Service desired_count ignored when autoscaling enabled
- Container Insights enabled by default
- Private subnet deployment (assign_public_ip = false)
- Comprehensive tagging strategy
- Log retention to prevent unbounded costs

### Use Cases
- **Web Applications**: ALB integration, auto-scaling, multiple availability zones
- **Microservices**: Service discovery, isolated task roles, multi-container tasks
- **Batch Processing**: Fargate Spot for cost savings, EFS for shared data
- **APIs**: Auto-scaling based on request count, Container Insights monitoring
- **Background Workers**: SQS/SNS integration, task role permissions
- **Data Processing**: EFS volumes, multi-container sidecars

### Service Discovery
- AWS Cloud Map integration
- Private DNS namespace support
- Automatic service registration
- Health check integration
- Enables service-to-service communication

### ECS Exec Features
- Interactive shell access to running containers
- Debugging without SSH or bastion hosts
- Session logging to CloudWatch Logs
- IAM-based access control
- Requires Session Manager plugin

### Notes
- Fargate tasks run in `awsvpc` network mode (each task gets its own ENI)
- ECS Exec requires SSM Session Manager plugin installed locally
- Auto-scaling target changes to desired_count will be ignored by Terraform
- Task execution role is shared across all task definitions (unless overridden)
- Task roles are created per task definition (if policies specified)
- Log groups are automatically created with configured retention
- Container Insights requires CloudWatch agent (automatically deployed by AWS)
- Fargate Spot tasks may be interrupted with 2-minute warning
- Maximum 10 containers per task definition
- Maximum 1000 tasks per service

### Known Limitations
- Fargate doesn't support privileged containers
- Fargate doesn't support host network mode
- Fargate doesn't support custom CNI plugins
- ECS Exec requires additional IAM permissions
- Cannot use Docker volumes (use EFS instead)
- GPU workloads not supported on Fargate

### Migration Notes
- Existing task definitions must be recreated to use this module
- Service desired_count should be set initially, then managed by auto-scaling
- Load balancer target groups must be created separately
- Security groups for ECS tasks must allow health check traffic

## [Unreleased]

### Planned
- EC2 capacity provider support (Auto Scaling Group integration)
- Blue/green deployments with CodeDeploy
- Circuit breaker deployment configuration
- Service Connect integration
- Task Set support for external deployments
- Scheduled task support (EventBridge rules)
- Batch job support (ECS on Fargate)
- Additional runtime platforms (Windows, ARM64)
