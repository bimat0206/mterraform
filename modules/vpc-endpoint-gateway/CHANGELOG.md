# Changelog - VPC Gateway Endpoints Module

All notable changes to the VPC Gateway Endpoints module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of VPC Gateway Endpoints module
- S3 Gateway Endpoint support (FREE)
- DynamoDB Gateway Endpoint support (FREE)
- Automatic route table associations
- Optional IAM policy support for endpoints
- Dynamic naming based on organizational standards
- Comprehensive outputs (IDs, ARNs, prefix lists, CIDR blocks, states)
- Cost optimization documentation (FREE vs paid alternatives)

### Features
- **Zero Cost**: Gateway endpoints have no hourly or data processing charges
- **Route Table Association**: Automatically associates with specified route tables
- **Policy Support**: Optional IAM policies for access control
- **Regional**: Service names automatically adapted to current AWS region
- **High Performance**: Direct AWS backbone connectivity
- **Security**: Private connectivity without internet exposure

### Use Cases
- Private S3 access from EC2, Lambda, ECS
- Private DynamoDB access from applications
- Cost optimization (replace NAT Gateway for S3/DynamoDB traffic)
- Compliance requirements (no internet exposure)

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with at least one route table

### Example Usage
```hcl
module "vpc_gateway_endpoints" {
  source = "../modules/vpc-endpoint-gateway"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id              = module.vpc.vpc_id
  enable_s3_endpoint  = true
  enable_dynamodb_endpoint = true
  route_table_ids     = concat(
    [module.vpc.public_route_table_id],
    module.vpc.private_route_table_ids
  )

  tags = {}
}
```

### Documentation
- Comprehensive README with usage examples
- Cost comparison table
- Troubleshooting guide
- Security considerations
- Best practices
