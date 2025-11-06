# Network Account Configuration

Root Terraform configuration for the Network account in the AWS Landing Zone.

## Overview

This configuration deploys core networking infrastructure including:
- VPC with public and private subnets across multiple AZs
- Internet Gateway and NAT Gateway
- Optional ACM certificates with DNS validation

## Prerequisites

1. **AWS Credentials**: Configure AWS credentials via:
   - AWS CLI profile
   - Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
   - IAM role (for EC2/ECS)

2. **S3 Backend**: Create an S3 bucket and DynamoDB table for state management:
   ```bash
   # Create S3 bucket
   aws s3 mb s3://my-terraform-state-bucket --region ap-southeast-1

   # Enable versioning
   aws s3api put-bucket-versioning \
     --bucket my-terraform-state-bucket \
     --versioning-configuration Status=Enabled

   # Create DynamoDB table for state locking
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region ap-southeast-1
   ```

3. **Route53 Hosted Zone** (optional, only if using ACM):
   - Create a Route53 hosted zone for your domain
   - Note the hosted zone ID

## Configuration

### 1. Backend Configuration

Copy the example backend config and customize:

```bash
cp backend.hcl.example backend.hcl
```

Edit `backend.hcl` with your values:
```hcl
bucket         = "my-terraform-state-bucket"
key            = "network-account/terraform.tfstate"
region         = "ap-southeast-1"
dynamodb_table = "terraform-state-lock"
encrypt        = true
```

**Note**: Do NOT commit `backend.hcl` to version control.

### 2. Environment Variables

Create environment-specific variable files:

**For Development:**
```bash
# dev.tfvars is already created - customize as needed
```

**For Production:**
```bash
# prod.tfvars is already created - customize as needed
```

Or create custom environment files:
```bash
cp terraform.tfvars.example staging.tfvars
# Edit staging.tfvars
```

## Usage

### Initialize Terraform

```bash
terraform init -backend-config=backend.hcl
```

### Plan Changes

```bash
# Development
terraform plan -var-file=dev.tfvars

# Production
terraform plan -var-file=prod.tfvars
```

### Apply Changes

```bash
# Development
terraform apply -var-file=dev.tfvars

# Production
terraform apply -var-file=prod.tfvars
```

### Destroy Resources

```bash
terraform destroy -var-file=dev.tfvars
```

## Configuration Options

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| region | AWS region | "ap-southeast-1" |
| org_prefix | Organization prefix | "tsk" |
| environment | Environment name | "dev", "prod" |
| workload | Workload name | "app", "platform" |
| vpc_cidr_block | VPC CIDR block | "10.0.0.0/16" |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| vpc_az_count | Number of AZs | 2 |
| vpc_enable_nat_gateway | Enable NAT Gateway | true |
| acm_enabled | Create ACM certificate | false |
| tags | Additional resource tags | {} |

## Outputs

After applying, you can view outputs:

```bash
terraform output
```

Key outputs:
- `vpc_id`: VPC identifier
- `public_subnet_ids`: Public subnet IDs
- `private_subnet_ids`: Private subnet IDs
- `nat_gateway_public_ip`: NAT Gateway public IP
- `acm_certificate_arn`: ACM certificate ARN (if enabled)

## Resource Naming

All resources follow the naming pattern:
```
{org_prefix}-{environment}-{workload}-{service}-{identifier}
```

Example: `tsk-dev-app-vpc-01`

## Tagging Strategy

Tags are applied in two layers:

1. **Provider default_tags** (automatic):
   - `terraform = "true"`
   - `managed-by = "terraform"`
   - `org = <org_prefix>`
   - `environment = <environment>`
   - `workload = <workload>`

2. **Module tags** (from `.tfvars`):
   - `owner`: Team or individual
   - `cost-center`: Cost allocation
   - `project`: Project name
   - Additional custom tags

## Environment Isolation

Each environment uses separate:
- Variable files (dev.tfvars, prod.tfvars)
- State files (via backend key)
- VPC CIDR blocks (to avoid conflicts)
- Resource names (via environment prefix)

## ACM Certificate Setup

To enable ACM certificate creation:

1. Set `acm_enabled = true` in your `.tfvars` file
2. Configure ACM variables:
   ```hcl
   acm_enabled                = true
   acm_domain_name            = "example.com"
   acm_subject_alternative_names = ["*.example.com"]
   acm_hosted_zone_id         = "Z1234567890ABC"
   ```
3. Apply the configuration

The certificate will be automatically validated via Route53 DNS.

## Troubleshooting

### Backend Initialization Fails

Ensure:
- S3 bucket exists and you have access
- DynamoDB table exists
- AWS credentials are configured
- Region matches in backend.hcl

### State Lock Timeout

If apply/plan hangs with lock timeout:
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### Module Not Found

Ensure you're running from the network-account directory:
```bash
cd network-account
terraform init -backend-config=backend.hcl
```

## Best Practices

1. **Never commit sensitive files**:
   - *.tfvars (except .example)
   - backend.hcl
   - .terraform/
   - *.tfstate

2. **Use remote state**:
   - Always configure S3 backend
   - Enable versioning on state bucket
   - Use DynamoDB for state locking

3. **Plan before apply**:
   - Always run `terraform plan` first
   - Review changes carefully
   - Use `-out=plan.tfplan` for complex changes

4. **Environment isolation**:
   - Use separate state files per environment
   - Use different VPC CIDR blocks
   - Tag resources appropriately

5. **Module versioning**:
   - Pin module versions in production
   - Test changes in dev first
   - Use semantic versioning

## File Structure

```
network-account/
├── README.md                  # This file
├── backend.tf                 # S3 backend (values via -backend-config)
├── backend.hcl.example        # Example backend config
├── providers.tf               # AWS provider with default_tags
├── versions.tf                # Terraform and provider versions
├── variables.tf               # Input variable declarations
├── locals.tf                  # Local values
├── main.tf                    # Module calls
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Documented example values
├── dev.tfvars                 # Development environment config
└── prod.tfvars                # Production environment config
```

## Support

For issues or questions:
1. Check module READMEs in `../modules/`
2. Review AWS provider documentation
3. Consult Terraform AWS examples
