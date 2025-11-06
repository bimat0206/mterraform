# Changelog - VPC Module

All notable changes to the VPC module will be documented in this file.

## [2.0.0] - 2025-11-06

### Changed
- **BREAKING**: Removed VPC endpoint resources (moved to separate modules)
- **BREAKING**: Removed `enable_s3_endpoint` variable
- **BREAKING**: Removed `enable_dynamodb_endpoint` variable
- **BREAKING**: Removed `enable_interface_endpoints` variable
- **BREAKING**: Removed `vpc_endpoint_*` outputs

### Removed
- VPC Gateway Endpoints (S3, DynamoDB) - now in `vpc-endpoint-gateway` module
- VPC Interface Endpoints - now in `vpc-endpoint-interface` module
- Interface endpoints security group
- Endpoint-related local variables

### Why This Change?
Separating VPC endpoints into dedicated modules provides:
- Better modularity and reusability
- Independent lifecycle management
- Clearer cost attribution
- Easier testing and maintenance
- Ability to create multiple endpoint configurations per VPC

### Migration
See root CHANGELOG.md for migration guide from v1.x to v2.0.

## [1.0.0] - 2025-11-06

### Added
- VPC with configurable CIDR blocks and IPv6 support
- Secondary CIDR blocks for VPC expansion
- Public, private, and database subnets across multiple AZs
- Internet Gateway for public subnets
- NAT Gateway with flexible deployment (single, per-AZ, or none)
- VPN Gateway with route propagation
- VPC Flow Logs (CloudWatch or S3)
- VPC Endpoints (Gateway and Interface) - now removed in v2.0
- DHCP Options configuration
- Network ACLs (default and dedicated)
- Default Security Group management
- Default Route Table management
- RDS database subnet groups
- 50+ comprehensive outputs
- Dynamic naming convention
- Consistent tagging support

### Features
- Multi-AZ design (1-6 availability zones)
- IPv6 dual-stack networking
- Automatic subnet CIDR calculation
- Per-AZ route tables for HA
- Cost-optimized and HA NAT strategies
- DNS hostnames and support
- Instance tenancy configuration
