# Changelog - VPC Interface Endpoints Module

All notable changes to the VPC Interface Endpoints module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of VPC Interface Endpoints module
- Support for all AWS services with interface endpoints
- Auto-created security group with HTTPS (port 443) ingress
- Private DNS enablement for automatic service resolution
- Multi-AZ deployment across specified subnets
- Configurable allowed CIDR blocks
- Option to use custom security groups
- Dynamic naming based on organizational standards
- Comprehensive outputs (IDs, ARNs, DNS entries, ENI IDs, states)

### Features
- **AWS PrivateLink**: Private connectivity to AWS services
- **Security Group**: Auto-created with HTTPS from VPC CIDR
- **Private DNS**: Automatic DNS resolution for service endpoints
- **Multi-AZ**: High availability across availability zones
- **Flexible**: Support for 100+ AWS services
- **Cost Tracking**: Per-endpoint tagging for cost allocation

### Supported Services
Common endpoints include:
- Compute: ec2, ec2messages, ecs, ecs-agent, ecs-telemetry
- Management: ssm, ssmmessages, logs, monitoring
- Storage: ecr.api, ecr.dkr, elasticfilesystem
- Security: kms, secretsmanager, sts
- Database: rds, elasticache
- Developer Tools: codecommit, codebuild, codedeploy

### Cost Information
- **Hourly**: $0.01/hour per AZ ≈ $7.20/month per endpoint (single AZ)
- **Data Transfer**: $0.01/GB processed
- **Example**: 3 endpoints × 3 AZs = ~$64.80/month + data

### Use Cases
- SSM Session Manager access without internet
- ECR image pulls in private subnets
- Lambda functions accessing AWS services in VPC
- ECS tasks with private service access
- Fully private VPCs (no NAT Gateway or IGW)

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with DNS hostnames and DNS support enabled
- Private subnets for endpoint placement

### Example Usage

**SSM Session Manager:**
```hcl
module "ssm_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  endpoints = {
    ssm         = true
    ssmmessages = true
    ec2messages = true
  }

  tags = {}
}
```

**ECS with ECR:**
```hcl
module "ecs_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "ecs"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids

  endpoints = {
    ecs           = true
    ecs-agent     = true
    ecs-telemetry = true
    ecr.api       = true
    ecr.dkr       = true
    logs          = true
  }

  tags = {}
}
```

### Security
- Security group restricts access to HTTPS (443) only
- Source CIDR automatically includes VPC CIDR
- Additional CIDRs can be specified (e.g., for VPN)
- Private DNS ensures applications use private IPs
- All traffic stays within AWS network

### Cost Optimization
- **When to Use**: Private access required, compliance needs, or NAT costs exceed endpoint costs
- **When NOT to Use**: Service has gateway endpoint (S3, DynamoDB), or NAT Gateway is cheaper
- **Tip**: Only create endpoints for services you actively use

### Documentation
- Comprehensive README with usage examples
- Common endpoint combinations (SSM, ECS, Lambda)
- Cost comparison and optimization guidance
- Troubleshooting guide
- Security best practices
- Migration guide from VPC module
