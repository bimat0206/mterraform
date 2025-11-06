# AWS Landing Zone Terraform

Minimal AWS Landing Zone blueprint with reusable Terraform modules for multi-account AWS organizations.

## Structure

```
aws-landing-zone-terraform/
├── modules/           # Reusable Terraform modules
│   ├── vpc/          # VPC with public/private subnets, NAT, IGW
│   └── acm/          # ACM certificate with DNS validation
└── network-account/   # Root configuration for Network account
```

## Features

- **Dynamic naming convention**: All resources follow `{org_prefix}-{environment}-{workload}-{service}-{identifier}` pattern
- **Consistent tagging**: Centralized tag management via `.tfvars` files
- **Environment isolation**: Separate `.tfvars` files for dev, prod, etc.
- **Remote state**: S3 backend configuration with `-backend-config`
- **Provider best practices**: No providers in modules, default tags in root

## Modules

### VPC Module
Creates a VPC with:
- Public and private subnets across multiple AZs
- Internet Gateway
- NAT Gateway (optional)
- Route tables and associations

### ACM Module
Creates ACM certificates with:
- DNS validation via Route53
- Support for Subject Alternative Names (SANs)
- Automatic validation completion

## Requirements

- Terraform >= 1.6.0
- AWS provider ~> 5.0
- AWS credentials configured (profile, assume role, or environment variables)

## Usage

See individual account directories (e.g., `network-account/`) for specific usage instructions.

## Naming Convention

All resources are named using a token-based pattern:
- **org_prefix**: Organization identifier (e.g., "tsk")
- **environment**: Environment name (e.g., "dev", "prod")
- **workload**: Workload type (e.g., "app", "platform")
- **service**: Service name (e.g., "vpc", "acm")
- **identifier**: Unique identifier (e.g., "01", "a")

Example: `tsk-dev-app-vpc-01`

## Tagging Strategy

Base tags are applied via:
1. **Provider default_tags**: Automatic tags on all supported resources
2. **Module tags**: Additional tags passed from `.tfvars` files

Recommended tags:
- `environment`: dev, prod, staging
- `owner`: Team or individual owner
- `cost-center`: Cost allocation code
- `project`: Project name
- `managed-by`: "terraform"