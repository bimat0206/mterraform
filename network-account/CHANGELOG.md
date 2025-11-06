# Changelog - Network Account Configuration

All notable changes to the Network Account root configuration will be documented in this file.

## [2.0.0] - 2025-11-06

### Added
- New VPC Gateway Endpoints module integration
- New VPC Interface Endpoints module integration
- Variables for gateway endpoints (`vpce_gateway_enabled`, `vpce_enable_s3_endpoint`, `vpce_enable_dynamodb_endpoint`)
- Variables for interface endpoints (`vpce_interface_enabled`, `vpce_interface_endpoints`, `vpce_private_dns_enabled`)
- Outputs for gateway endpoints (S3, DynamoDB)
- Outputs for interface endpoints (IDs, security group, endpoint list)
- Updated `terraform.tfvars.example` with new endpoint module configuration
- Separate module calls for VPC endpoints in `main.tf`

### Changed
- **BREAKING**: VPC endpoint configuration moved from VPC module to separate modules
- **BREAKING**: Variable names changed from `vpc_enable_*_endpoint` to `vpce_enable_*_endpoint`
- **BREAKING**: Interface endpoints now use dedicated module instead of VPC module
- Updated `main.tf` to call new endpoint modules
- Updated `outputs.tf` with new endpoint outputs

### Removed
- VPC endpoint variables from VPC module call
- `vpc_enable_s3_endpoint` from VPC module
- `vpc_enable_dynamodb_endpoint` from VPC module
- `vpc_enable_interface_endpoints` from VPC module

### Migration Guide

**Step 1: Update variables in your .tfvars files**

Old format (v1.x):
```hcl
vpc_enable_s3_endpoint       = true
vpc_enable_dynamodb_endpoint = true
vpc_enable_interface_endpoints = {
  ec2 = true
  ssm = true
}
```

New format (v2.0):
```hcl
# Enable gateway endpoints module
vpce_gateway_enabled = true
vpce_enable_s3_endpoint       = true
vpce_enable_dynamodb_endpoint = true

# Enable interface endpoints module
vpce_interface_enabled = true
vpce_interface_endpoints = {
  ec2 = true
  ssm = true
}
vpce_private_dns_enabled = true
```

**Step 2: Run Terraform**
```bash
terraform init -upgrade    # Upgrade modules
terraform plan             # Review changes
terraform apply            # Apply changes
```

### Benefits of This Change
- **Modularity**: Endpoints can be managed independently
- **Cost Visibility**: Separate modules for better cost attribution
- **Flexibility**: Different lifecycle management for endpoints
- **Reusability**: Endpoint modules can be used with any VPC
- **Clarity**: Clear separation between VPC networking and endpoints

## [1.0.0] - 2025-11-06

### Added
- Initial network account configuration
- VPC module integration with comprehensive features
- ACM module integration for SSL/TLS certificates
- Provider configuration with default tags
- S3 backend configuration
- Local values for common naming and tagging
- Environment-specific variable files (dev.tfvars, prod.tfvars)
- Comprehensive terraform.tfvars.example with documentation
- Backend configuration example (backend.hcl.example)
- Detailed README with usage instructions

### Features
- **VPC**: Complete networking setup with public/private/database subnets
- **NAT Gateway**: Flexible deployment strategies (single, per-AZ, none)
- **VPN Gateway**: Site-to-site VPN connectivity
- **Flow Logs**: CloudWatch or S3 logging
- **DHCP Options**: Custom DNS and NTP configuration
- **Network ACLs**: Dedicated ACLs for subnet tiers
- **ACM Certificates**: Automatic SSL/TLS with DNS validation
- **Provider Tags**: Automatic tagging via default_tags
- **Backend**: S3 state storage with DynamoDB locking

### Configuration Files
- `backend.tf`: S3 backend configuration
- `providers.tf`: AWS provider with default tags
- `versions.tf`: Terraform and provider version constraints
- `variables.tf`: All input variable declarations
- `locals.tf`: Common naming and tagging locals
- `main.tf`: Module calls for VPC, endpoints, ACM
- `outputs.tf`: Output definitions
- `terraform.tfvars.example`: Documented example configuration
- `dev.tfvars`: Development environment configuration
- `prod.tfvars`: Production environment configuration
- `backend.hcl.example`: Example backend configuration

### Usage
```bash
# Initialize
terraform init -backend-config=backend.hcl

# Plan
terraform plan -var-file=dev.tfvars

# Apply
terraform apply -var-file=dev.tfvars
```

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- S3 bucket for state storage
- DynamoDB table for state locking
- AWS credentials configured
