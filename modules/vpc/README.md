# VPC Module

Creates an AWS VPC with public and private subnets across multiple Availability Zones, including Internet Gateway and optional NAT Gateway.

## Features

- VPC with configurable CIDR block
- Public subnets with Internet Gateway
- Private subnets with optional NAT Gateway
- Automatic subnet CIDR calculation across AZs
- DNS hostnames and DNS support enabled
- Consistent naming and tagging

## Usage

```hcl
module "vpc" {
  source = "../modules/vpc"

  # Naming inputs
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  service     = "vpc"
  identifier  = "01"

  # VPC configuration
  cidr_block         = "10.0.0.0/16"
  az_count           = 2
  enable_nat_gateway = true

  # Tags
  tags = {
    owner       = "cloud-platform"
    cost-center = "CC-1234"
    project     = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_prefix | Organization prefix for resource naming | string | - | yes |
| environment | Environment name (dev, prod, staging) | string | - | yes |
| workload | Workload name | string | - | yes |
| service | Service name override | string | null | no |
| identifier | Unique identifier | string | null | no |
| tags | Additional tags | map(string) | {} | no |
| cidr_block | CIDR block for the VPC | string | - | yes |
| az_count | Number of AZs to use | number | 2 | no |
| enable_nat_gateway | Enable NAT Gateway | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_name | The name of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| public_subnet_cidrs | List of public subnet CIDR blocks |
| private_subnet_cidrs | List of private subnet CIDR blocks |
| internet_gateway_id | The ID of the Internet Gateway |
| nat_gateway_id | The ID of the NAT Gateway (if enabled) |
| nat_gateway_public_ip | The public IP of the NAT Gateway |
| public_route_table_id | The ID of the public route table |
| private_route_table_id | The ID of the private route table |
| availability_zones | List of availability zones used |

## Resource Naming

Resources are named using the pattern: `{org_prefix}-{environment}-{workload}-{service}-{identifier}`

Example: `tsk-dev-app-vpc-01`

## Notes

- Uses a single NAT Gateway in the first public subnet for cost optimization
- Public subnets have `map_public_ip_on_launch` enabled
- Subnet CIDR blocks are automatically calculated based on VPC CIDR and AZ count
- DNS hostnames and support are enabled by default
