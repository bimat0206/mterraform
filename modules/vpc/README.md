# VPC Module

Production-ready AWS VPC module with comprehensive features for building secure, scalable network infrastructure.

## Features

### Core Networking
- **VPC**: Configurable CIDR blocks, instance tenancy, DNS settings
- **Secondary CIDR Blocks**: Expand VPC address space
- **IPv6 Support**: Dual-stack networking with automatic CIDR assignment
- **Subnets**: Public, private, and database subnets across multiple AZs
- **Internet Gateway**: Internet connectivity for public subnets
- **NAT Gateway**: Flexible NAT configuration (single, per-AZ, or none)

### Advanced Features
- **VPN Gateway**: Site-to-site VPN connectivity with route propagation
- **VPC Flow Logs**: CloudWatch or S3 logging with custom IAM roles
- **VPC Endpoints**: Gateway (S3, DynamoDB) and interface endpoints
- **DHCP Options**: Custom DNS, NTP, and NetBIOS configuration
- **Database Subnet Groups**: Auto-created RDS subnet groups

### Security & Governance
- **Network ACLs**: Dedicated ACLs for public/private subnets
- **Default Resource Management**: Control default SG, NACL, and route tables
- **Security Groups**: Auto-created SG for VPC endpoints
- **Consistent Tagging**: Dynamic naming and tag inheritance

### High Availability
- **Multi-AZ Design**: 1-6 availability zones
- **NAT Gateway HA**: One NAT per AZ option for redundancy
- **Per-AZ Route Tables**: Isolated routing for HA architectures

## Quick Start

```hcl
module "vpc" {
  source = "../modules/vpc"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  # Basic VPC
  cidr_block = "10.0.0.0/16"
  az_count   = 3

  # Enable production features
  enable_nat_gateway      = true
  one_nat_gateway_per_az  = true
  enable_flow_logs        = true
  enable_s3_endpoint      = true

  tags = {}
}
```

## Requirements

- Terraform >= 1.6.0
- AWS Provider ~> 5.0
