# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2025-11-06

### Added
- New `vpc-endpoint-gateway` module for managing S3 and DynamoDB gateway endpoints
- New `vpc-endpoint-interface` module for managing interface VPC endpoints
- Separate VPC endpoint modules for better modularity and reusability
- Comprehensive README documentation for each endpoint module
- Cost optimization guidance for VPC endpoints

### Changed
- **BREAKING**: Removed VPC endpoint configuration from VPC module
- **BREAKING**: VPC endpoints now require separate module calls
- Updated `network-account` to use new endpoint modules
- Refactored endpoint variables with `vpce_` prefix for clarity

### Removed
- VPC endpoint resources from `modules/vpc/main.tf`
- VPC endpoint variables from `modules/vpc/variables.tf`
- VPC endpoint outputs from `modules/vpc/outputs.tf`

### Migration Guide
**Old Configuration (v1.x):**
```hcl
module "vpc" {
  source = "../modules/vpc"

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  enable_interface_endpoints = {
    ec2 = true
    ssm = true
  }
}
```

**New Configuration (v2.0):**
```hcl
module "vpc" {
  source = "../modules/vpc"
  # VPC endpoint variables removed
}

module "vpc_gateway_endpoints" {
  source = "../modules/vpc-endpoint-gateway"

  vpc_id              = module.vpc.vpc_id
  enable_s3_endpoint  = true
  enable_dynamodb_endpoint = true
  route_table_ids     = module.vpc.private_route_table_ids
}

module "vpc_interface_endpoints" {
  source = "../modules/vpc-endpoint-interface"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_subnet_ids
  endpoints      = {
    ec2 = true
    ssm = true
  }
}
```

## [1.0.0] - 2025-11-06

### Added
- Initial VPC module with comprehensive production features
- VPC Flow Logs support (CloudWatch and S3)
- VPN Gateway integration
- DHCP Options configuration
- Network ACLs management
- Database subnets with RDS subnet groups
- IPv6 support
- Secondary CIDR blocks
- Flexible NAT Gateway strategies (single, per-AZ, none)
- ACM module for SSL/TLS certificates
- Network account root configuration
- Terraform >= 1.6.0 and AWS provider ~> 5.0
- Dynamic resource naming convention
- Consistent tagging strategy
- Comprehensive documentation and examples
