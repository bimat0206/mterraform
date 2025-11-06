# VPC Interface Endpoints Module

Creates AWS VPC Interface Endpoints for private connectivity to AWS services. Interface endpoints use AWS PrivateLink and eliminate the need for internet gateways, NAT devices, or VPN connections.

## Features

- **Private DNS**: Automatic private DNS resolution for AWS services
- **Security Group**: Auto-created security group with configurable rules
- **Multi-AZ**: Endpoints span specified subnets for high availability
- **Flexible Services**: Support for all AWS services with interface endpoints
- **Cost Tracking**: Per-endpoint resource tagging for cost allocation
- **Consistent Naming**: Dynamic naming based on organizational standards

## Cost

Interface endpoints cost approximately **$7.20/month per endpoint** plus data transfer charges (~$0.01/GB). Consider using gateway endpoints (FREE) for S3 and DynamoDB instead.

## Supported Services

Common interface endpoints include:

- **Compute**: ec2, ec2messages, ecs, ecs-agent, ecs-telemetry
- **Management**: ssm, ssmmessages, logs, monitoring
- **Storage**: ecr.api, ecr.dkr, elasticfilesystem
- **Security**: kms, secretsmanager, sts
- **Database**: rds, elasticache
- **Developer Tools**: codecommit, codebuild, codedeploy
- **And many more...**

## Usage

### Basic Usage

```hcl
module "vpc_interface_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  identifier  = "01"

  # VPC Configuration
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  # Enable common endpoints
  endpoints = {
    ec2      = true
    ssm      = true
    ssmmessages = true
    ec2messages = true
  }

  tags = {}
}
```

### Systems Manager (SSM) Access

```hcl
module "ssm_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  # Minimum required for SSM Session Manager
  endpoints = {
    ssm         = true  # Systems Manager
    ssmmessages = true  # Session Manager
    ec2messages = true  # EC2 communication
  }

  private_dns_enabled = true

  tags = {}
}
```

### Container Registry Access (ECS/EKS)

```hcl
module "ecr_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  # ECR endpoints for pulling container images
  endpoints = {
    ecr.api = true  # ECR API
    ecr.dkr = true  # ECR Docker registry
  }

  # Also need S3 gateway endpoint (separate module) for layer downloads

  tags = {}
}
```

### Custom Security Group

```hcl
module "vpc_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  endpoints = {
    ec2 = true
    ssm = true
  }

  # Use existing security group
  create_security_group = false
  security_group_ids    = [aws_security_group.custom.id]

  tags = {}
}
```

### Additional CIDR Blocks

```hcl
module "vpc_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  endpoints = {
    ssm = true
  }

  # Allow access from on-premises network via VPN
  allowed_cidr_blocks = [
    "192.168.0.0/16"  # On-premises network
  ]

  tags = {}
}
```

## Variables

### Naming Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| org_prefix | string | - | Organization prefix (Required) |
| environment | string | - | Environment name (Required) |
| workload | string | - | Workload name (Required) |
| service | string | null | Service override (default: "vpce-if") |
| identifier | string | null | Unique identifier |
| tags | map(string) | {} | Additional tags |

### Configuration Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| vpc_id | string | - | VPC ID (Required) |
| vpc_cidr_block | string | - | VPC CIDR block (Required) |
| subnet_ids | list(string) | - | Subnet IDs for endpoints (Required) |
| endpoints | map(bool) | {} | Map of services to enable |
| private_dns_enabled | bool | true | Enable private DNS |
| create_security_group | bool | true | Create security group |
| security_group_ids | list(string) | [] | Existing SG IDs (if create_security_group=false) |
| allowed_cidr_blocks | list(string) | [] | Additional CIDR blocks |
| security_group_description | string | "Security group for VPC interface endpoints" | SG description |

## Outputs

### Security Group Outputs

| Name | Description |
|------|-------------|
| security_group_id | Security group ID |
| security_group_arn | Security group ARN |
| security_group_name | Security group name |

### Endpoint Outputs

| Name | Description |
|------|-------------|
| endpoint_ids | Map of service names to endpoint IDs |
| endpoint_arns | Map of service names to endpoint ARNs |
| endpoint_dns_entries | Map of service names to DNS entries |
| endpoint_network_interface_ids | Map of service names to ENI IDs |
| endpoint_states | Map of service names to states |
| endpoint_count | Number of endpoints created |
| endpoints_created | List of endpoint service names |

## Resource Naming

Resources are named using: `{org_prefix}-{environment}-{workload}-{service}-{identifier}-{aws_service}`

Example: `tsk-prod-app-vpce-if-01-ssm`

## Common Endpoint Combinations

### SSM Session Manager
```hcl
endpoints = {
  ssm         = true
  ssmmessages = true
  ec2messages = true
}
```

### ECS Fargate
```hcl
endpoints = {
  ecs         = true
  ecs-agent   = true
  ecs-telemetry = true
  ecr.api     = true
  ecr.dkr     = true
  logs        = true
}
# Plus S3 gateway endpoint for layer downloads
```

### Lambda in VPC
```hcl
endpoints = {
  lambda     = true
  logs       = true
  monitoring = true
  sts        = true
}
```

### Secrets Manager
```hcl
endpoints = {
  secretsmanager = true
  kms            = true  # If secrets are encrypted with KMS
}
```

## Cost Optimization

### Gateway vs Interface Endpoints

| Service | Endpoint Type | Monthly Cost |
|---------|---------------|--------------|
| S3 | Gateway | $0 (FREE) |
| DynamoDB | Gateway | $0 (FREE) |
| SSM | Interface | ~$7.20 + data |
| EC2 | Interface | ~$7.20 + data |
| All Others | Interface | ~$7.20 + data |

**Key Takeaway**: Use gateway endpoints for S3 and DynamoDB (separate module). Only use interface endpoints for services that require them.

### Cost Estimation

For interface endpoints:
- **Hourly**: $0.01/hour per AZ = ~$7.20/month per endpoint (single AZ)
- **Data Transfer**: $0.01/GB processed
- **Example**: 3 endpoints × 3 AZs = ~$64.80/month + data

### When to Use Interface Endpoints

✅ **Use when:**
- You need private access to AWS services
- You want to eliminate NAT Gateway costs for specific services
- Compliance requires private connectivity
- You're building a fully private VPC

❌ **Don't use when:**
- Service has a gateway endpoint option (S3, DynamoDB)
- NAT Gateway is cheaper for your traffic patterns
- Public internet access is acceptable

## Best Practices

1. **Subnet Selection**: Use private subnets across multiple AZs for HA
2. **Security Groups**: Use the auto-created security group (port 443 only)
3. **Private DNS**: Keep enabled unless you have specific DNS requirements
4. **Cost Monitoring**: Tag endpoints for cost tracking per service
5. **Selective Enablement**: Only create endpoints you actively use
6. **Gateway First**: Always use gateway endpoints for S3/DynamoDB

## Security Considerations

- Interface endpoints use **security groups** (unlike gateway endpoints)
- Default security group allows HTTPS (443) from VPC CIDR
- Private DNS ensures applications use private IPs automatically
- Endpoints are highly available (span multiple AZs)
- All traffic stays within AWS network

## Troubleshooting

### Endpoint Not Working

1. **Check DNS resolution**: `nslookup service-name.region.amazonaws.com`
2. **Verify security group**: Ensure port 443 is allowed from source
3. **Check private DNS**: Should be enabled for automatic resolution
4. **Verify subnet**: Endpoint ENIs should be in correct subnets
5. **Review VPC settings**: DNS hostnames and resolution must be enabled in VPC

### High Costs

1. **Count endpoints**: Each endpoint × AZ × $7.20/month
2. **Review necessity**: Remove unused endpoints
3. **Consider gateway endpoints**: Use free S3/DynamoDB gateway endpoints
4. **Monitor data transfer**: Check data processing charges

### DNS Not Resolving

1. **Enable private DNS**: Set `private_dns_enabled = true`
2. **Check VPC DNS settings**: `enableDnsHostnames` and `enableDnsSupport` must be true
3. **Wait for propagation**: DNS changes may take a few minutes

## Examples

See `../../network-account/` for complete examples using this module.

## Requirements

- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with DNS hostnames and DNS support enabled

## Related Modules

- `../vpc/` - VPC infrastructure
- `../vpc-endpoint-gateway/` - Gateway VPC endpoints (FREE for S3/DynamoDB)

## Migration from VPC Module

If migrating from the VPC module's built-in endpoints:

```hcl
# Old (in VPC module)
vpc_enable_interface_endpoints = {
  ec2 = true
  ssm = true
}

# New (separate module)
module "vpc_interface_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  endpoints = {
    ec2 = true
    ssm = true
  }
}
```
