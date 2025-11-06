# Workload Account Configuration

Terraform configuration for deploying workload resources (EC2 instances) in the AWS Landing Zone workload account. This account is intended for running application workloads, both Linux and Windows-based.

## Overview

The workload account hosts compute resources that run your applications. This configuration supports:
- Linux EC2 instances (Amazon Linux 2023, Ubuntu, RHEL, etc.)
- Windows EC2 instances (Windows Server 2022, 2019, 2016)
- Both public-facing and private instances
- SSH and RDP access, or SSM Session Manager
- IAM instance profiles with SSM support
- Encrypted EBS volumes
- Flexible security group configurations

## Architecture

```
Workload Account
├── EC2 Linux Instance (optional)
│   ├── Auto-discovered or custom AMI
│   ├── Security Group (SSH)
│   ├── IAM Instance Profile (SSM)
│   └── Encrypted EBS volumes
└── EC2 Windows Instance (optional)
    ├── Auto-discovered or custom AMI
    ├── Security Group (RDP, WinRM)
    ├── IAM Instance Profile (SSM)
    └── Encrypted EBS volumes
```

## Prerequisites

1. **Network Account Deployed**: VPC and subnets must exist in the network account
2. **AWS Account**: Dedicated workload AWS account in your organization
3. **EC2 Key Pairs** (optional): For SSH/RDP access
4. **Terraform**: Version >= 1.6.0
5. **AWS Credentials**: Configured with appropriate permissions

## Directory Structure

```
workload-account/
├── README.md                    # This file
├── versions.tf                  # Terraform version constraints
├── backend.tf                   # S3 backend configuration
├── backend.hcl.example          # Example backend config
├── providers.tf                 # AWS provider configuration
├── locals.tf                    # Local values
├── variables.tf                 # Input variables
├── main.tf                      # EC2 module configurations
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example variable values
├── dev.tfvars                   # Development environment (create from example)
└── prod.tfvars                  # Production environment (create from example)
```

## Quick Start

### 1. Configure Backend

```bash
cp backend.hcl.example backend.hcl
# Edit backend.hcl with your S3 bucket and DynamoDB table
```

### 2. Create Environment Configuration

```bash
cp terraform.tfvars.example dev.tfvars
# Edit dev.tfvars with your values
```

### 3. Initialize Terraform

```bash
terraform init -backend-config=backend.hcl
```

### 4. Plan and Apply

```bash
# Review changes
terraform plan -var-file=dev.tfvars

# Apply configuration
terraform apply -var-file=dev.tfvars
```

## Network Account Integration

The workload account requires network resources from the network account. You can import these using:

### Option 1: Direct Variable Input

In your `.tfvars` file:
```hcl
vpc_id             = "vpc-0123456789abcdef"
private_subnet_ids = ["subnet-abc", "subnet-def"]
public_subnet_ids  = ["subnet-xyz", "subnet-uvw"]
```

### Option 2: Remote State Data Source (Recommended)

Add to `main.tf`:
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "your-terraform-state-bucket"
    key    = "network-account/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Then use in module configurations:
vpc_id = data.terraform_remote_state.network.outputs.vpc_id
```

## Usage Examples

### Linux Web Server

Deploy a Linux instance with Nginx in a public subnet:

```hcl
# dev.tfvars
ec2_linux_enabled           = true
ec2_linux_instance_type     = "t3.small"
ec2_linux_key_name          = "my-keypair"
ec2_linux_associate_public_ip = true

ec2_linux_user_data = <<-EOT
  #!/bin/bash
  yum update -y
  yum install -y nginx
  systemctl start nginx
  systemctl enable nginx
EOT

ec2_linux_security_group_ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]
    description = "SSH from office"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }
]
```

### Linux App Server with SSM

Deploy a private Linux instance with SSM Session Manager (no SSH):

```hcl
# prod.tfvars
ec2_linux_enabled           = true
ec2_linux_instance_type     = "t3.small"
ec2_linux_associate_public_ip = false
ec2_linux_create_iam_profile = true
ec2_linux_security_group_ingress_rules = []  # No inbound access
```

Connect using SSM:
```bash
aws ssm start-session --target i-0123456789abcdef
```

### Windows Server

Deploy a Windows Server 2022 instance:

```hcl
# dev.tfvars
ec2_windows_enabled           = true
ec2_windows_instance_type     = "t3.medium"
ec2_windows_key_name          = "my-keypair"
ec2_windows_get_password_data = true
ec2_windows_associate_public_ip = false
ec2_windows_create_iam_profile = true

ec2_windows_security_group_ingress_rules = [
  {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "RDP from VPC"
  }
]
```

Retrieve Windows password:
```bash
terraform output -raw ec2_windows_password_data | base64 -d | openssl rsautl -decrypt -inkey /path/to/my-keypair.pem
```

### Mixed Environment

Deploy both Linux and Windows instances:

```hcl
# prod.tfvars
ec2_linux_enabled   = true
ec2_windows_enabled = true

ec2_linux_instance_type   = "t3.small"
ec2_windows_instance_type = "t3.medium"

ec2_linux_associate_public_ip   = false
ec2_windows_associate_public_ip = false

ec2_linux_create_iam_profile   = true
ec2_windows_create_iam_profile = true
```

## Modules Used

| Module | Source | Description |
|--------|--------|-------------|
| ec2_linux | ../modules/ec2-linux | Linux EC2 instance |
| ec2_windows | ../modules/ec2-windows | Windows EC2 instance |

## Cost Estimation

### Linux Instances (ap-southeast-1)
- **t3.micro**: ~$8.47/month (Free tier eligible)
- **t3.small**: ~$16.94/month
- **t3.medium**: ~$33.87/month
- **t3.large**: ~$67.74/month

### Windows Instances (ap-southeast-1)
- **t3.medium**: ~$34.94/month (minimum recommended)
- **t3.large**: ~$69.89/month
- **m5.large**: ~$93.44/month

### Additional Costs
- **EBS Storage (gp3)**: ~$0.092/GB-month
- **Detailed Monitoring**: $2.10/instance/month
- **Data Transfer**: Varies by region and volume

## Security Best Practices

1. **Private Subnets**: Deploy application servers in private subnets
2. **SSM Access**: Use Systems Manager Session Manager instead of SSH/RDP
3. **Security Groups**: Restrict CIDR blocks to known IP ranges
4. **IAM Roles**: Use instance profiles for AWS service access
5. **Encryption**: Enable EBS encryption (default in modules)
6. **No Credentials**: Never embed credentials in user data
7. **Regular Patching**: Apply OS security updates regularly
8. **Monitoring**: Enable CloudWatch monitoring and logging
9. **Termination Protection**: Enable for production instances
10. **Least Privilege**: Grant minimal required permissions

## Networking

### Subnet Selection

The configuration automatically selects the appropriate subnet:
- **Public Instances** (`associate_public_ip = true`): Uses `public_subnet_ids[0]`
- **Private Instances** (`associate_public_ip = false`): Uses `private_subnet_ids[0]`

### SSM Requirements

For SSM Session Manager to work without public IPs:
1. Deploy instances in private subnets
2. Ensure VPC has NAT Gateway OR VPC endpoints for SSM
3. Enable IAM instance profile (`create_iam_profile = true`)

Required VPC endpoints for fully private SSM:
- `com.amazonaws.region.ssm`
- `com.amazonaws.region.ssmmessages`
- `com.amazonaws.region.ec2messages`

## Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| region | string | AWS region |
| org_prefix | string | Organization prefix |
| environment | string | Environment name |
| workload | string | Workload name |
| tags | map(string) | Common tags |
| vpc_id | string | VPC ID from network account |
| private_subnet_ids | list(string) | Private subnet IDs |
| public_subnet_ids | list(string) | Public subnet IDs |

### Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| ec2_linux_enabled | bool | false | Create Linux instance |
| ec2_linux_instance_type | string | "t3.micro" | Linux instance type |
| ec2_windows_enabled | bool | false | Create Windows instance |
| ec2_windows_instance_type | string | "t3.medium" | Windows instance type |

See [terraform.tfvars.example](terraform.tfvars.example) for complete variable list.

## Outputs

| Name | Description |
|------|-------------|
| ec2_linux_instance_id | Linux instance ID |
| ec2_linux_private_ip | Linux private IP |
| ec2_linux_public_ip | Linux public IP (if assigned) |
| ec2_linux_ssh_command | SSH connection command |
| ec2_linux_ssm_command | SSM Session Manager command |
| ec2_windows_instance_id | Windows instance ID |
| ec2_windows_private_ip | Windows private IP |
| ec2_windows_public_ip | Windows public IP (if assigned) |
| ec2_windows_password_data | Encrypted Windows password (sensitive) |

## Troubleshooting

### Cannot connect to instance

**Problem**: SSH/RDP connection fails

**Solutions**:
1. Check security group allows required port (22 for SSH, 3389 for RDP)
2. Verify instance has public IP (if connecting from internet)
3. Check Network ACLs on subnet
4. Verify key permissions: `chmod 400 keypair.pem`

### SSM Session Manager not working

**Problem**: Cannot start SSM session

**Solutions**:
1. Verify IAM instance profile has `AmazonSSMManagedInstanceCore`
2. Ensure instance has internet access (NAT Gateway or VPC endpoints)
3. Check SSM agent is running: `sudo systemctl status amazon-ssm-agent`
4. Verify instance appears in Fleet Manager console

### Instance in wrong subnet

**Problem**: Instance deployed to wrong subnet type

**Solutions**:
1. Check `associate_public_ip` variable
2. Verify `public_subnet_ids` and `private_subnet_ids` values
3. Review `main.tf` subnet selection logic

## State Management

This configuration uses S3 backend for remote state:

```bash
# View current state
terraform state list

# Show specific resource
terraform state show module.ec2_linux[0].aws_instance.this

# Import existing resource
terraform import 'module.ec2_linux[0].aws_instance.this' i-0123456789abcdef
```

## Maintenance

### Updating Instances

User data changes:
```hcl
user_data_replace_on_change = true  # Force replacement on user data change
```

### Scaling

To add more instances:
1. Create additional module blocks in `main.tf`
2. Add corresponding variables
3. Update outputs

### Backup Strategy

Implement backups using:
- AWS Backup service
- EBS snapshots
- Custom AMI creation

## Related Documentation

- [EC2 Linux Module](../modules/ec2-linux/README.md)
- [EC2 Windows Module](../modules/ec2-windows/README.md)
- [Network Account](../network-account/README.md)
- [VPC Module](../modules/vpc/README.md)

## Support

For issues or questions:
1. Check module documentation
2. Review troubleshooting guide
3. Consult AWS documentation
4. Contact your cloud platform team

## License

This configuration is provided as-is for use within your organization.
