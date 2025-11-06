# Changelog - EC2 Windows Module

All notable changes to the EC2 Windows module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of EC2 Windows module
- Automatic AMI discovery for Windows Server (default: Windows Server 2022 Base)
- Support for custom AMI ID
- Configurable instance type with t3.medium default
- EC2 key pair integration for RDP password retrieval
- Windows password data retrieval capability
- User data support for PowerShell and batch scripts
- Auto-created security group with RDP (3389) and WinRM (5985-5986) access
- Configurable security group ingress/egress rules
- Optional IAM instance profile with SSM support
- Configurable root EBS volume (gp3, 50GB default, encrypted)
- Support for additional EBS volumes with flexible configuration
- IMDSv2 enforced by default for enhanced security
- Instance metadata tags support
- Detailed monitoring option
- Instance termination and stop protection
- Dynamic naming based on organizational standards
- Comprehensive outputs including connection information

### Features
- **Windows Support**: Full Windows Server integration
  - RDP access (port 3389)
  - WinRM HTTP/HTTPS (ports 5985-5986)
  - Password retrieval with key pair
  - PowerShell user data support
- **Security**: Security-first configuration
  - Auto-created security group
  - IMDSv2 enforced by default
  - EBS encryption enabled by default
  - IAM instance profile support
  - SSM agent integration
- **Storage**: Flexible EBS configuration
  - gp3 volumes by default (cost-optimized)
  - Configurable IOPS and throughput
  - KMS encryption support
  - Multiple additional volumes
- **Networking**: Comprehensive network options
  - Public or private subnet deployment
  - Static private IP support
  - Public IP association option
  - Source/destination checking control
- **High Availability**: Protection features
  - Termination protection
  - Stop protection
  - Configurable shutdown behavior

### Cost Information
- **t3.medium**: ~$34.94/month (2 vCPU, 4 GiB RAM) - recommended minimum for Windows
- **t3.large**: ~$69.89/month (2 vCPU, 8 GiB RAM)
- **m5.large**: ~$93.44/month (2 vCPU, 8 GiB RAM)
- **Storage (gp3)**: ~$0.092/GB-month
- **Detailed monitoring**: $2.10/instance/month (optional)

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with at least one subnet
- EC2 key pair (optional, for password retrieval)

### Use Cases
- Windows application servers
- Active Directory domain controllers
- SQL Server databases
- IIS web servers
- Windows-based development environments
- Jump hosts for RDP access
- Windows container hosts

### Default Configuration
- **Instance Type**: t3.medium (minimum recommended for Windows)
- **AMI**: Latest Windows Server 2022 Base (auto-discovered)
- **Root Volume**: gp3, 50 GB, encrypted
- **Security Group**: RDP (3389) and WinRM (5985-5986) from 0.0.0.0/0
- **IAM Policies**: AmazonSSMManagedInstanceCore (if IAM profile created)
- **IMDSv2**: Required (http_tokens = required)
- **Monitoring**: Basic (detailed monitoring disabled by default)

### Security Considerations
- Default security group rules allow RDP/WinRM from anywhere (0.0.0.0/0)
- **Production Recommendation**: Restrict CIDR blocks to known IPs
- **Best Practice**: Use AWS Systems Manager Session Manager instead of RDP
- IMDSv2 is enforced by default
- EBS encryption is enabled by default
- Consider using private subnets with VPN/Direct Connect

### Windows-Specific Features
- **Password Retrieval**: Set `get_password_data = true` and provide `key_name`
- **User Data**: PowerShell scripts in `<powershell>` tags or batch scripts
- **Device Naming**: Use `xvdf` through `xvdp` for additional EBS volumes
- **AMI Filters**: Default filter finds latest Windows Server 2022 Base

### Example Configurations

**Basic Windows Server:**
```hcl
module "windows" {
  source = "../modules/ec2-windows"

  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  instance_type = "t3.medium"
  key_name      = "my-keypair"

  tags = {}
}
```

**Windows with SSM (no RDP):**
```hcl
module "windows_ssm" {
  source = "../modules/ec2-windows"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  instance_type = "t3.large"

  create_iam_instance_profile = true
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  security_group_ingress_rules = []  # No inbound access

  tags = {}
}
```

**Windows Jump Host:**
```hcl
module "windows_jump" {
  source = "../modules/ec2-windows"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "jump"

  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true

  instance_type     = "t3.medium"
  key_name          = "my-keypair"
  get_password_data = true

  security_group_ingress_rules = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]  # Restricted to office IP
      description = "RDP from office"
    }
  ]

  disable_api_termination = true

  tags = {}
}
```

### Documentation
- Comprehensive README with usage examples
- Multiple deployment scenarios (basic, RDP, SSM, storage, custom AMI)
- Cost breakdown and optimization tips
- Security best practices
- Troubleshooting guide
- Windows password retrieval instructions
- WinRM connection information

### Outputs
- Instance: ID, ARN, name, state, type, AZ
- Network: Private/public IP and DNS
- Security: Security group ID, ARN, name
- IAM: Role and instance profile details
- Windows: Encrypted password data
- Storage: Root and EBS volume IDs
- Connection: RDP and WinRM info

### Integration
- Fully compatible with VPC module
- Supports VPC endpoints for SSM
- IAM integration for AWS service access
- CloudWatch integration for monitoring

### Known Limitations
- Windows password retrieval requires EC2 key pair
- Password data availability may take 3-5 minutes after launch
- Default security group rules are permissive (restrict in production)
- Minimum recommended instance type is t3.medium (Windows overhead)

### Migration Notes
- This is the initial release (no migration needed)
- Follow organizational naming convention standards
- Ensure VPC and subnet exist before deployment
- Create EC2 key pair if password retrieval is needed

### Related Modules
- `../vpc/` - VPC infrastructure for EC2 deployment
- `../ec2-linux/` - Linux EC2 instances
- `../vpc-endpoint-interface/` - VPC endpoints for SSM access

### AMI Support
- Windows Server 2022 (default)
- Windows Server 2019
- Windows Server 2016
- Windows Server with SQL Server editions
- Custom Windows AMIs

### Notes
- Windows Server licensing costs are included in EC2 pricing
- t3.medium is the minimum recommended instance type for Windows
- Consider using SSM Session Manager instead of RDP for better security
- Enable termination protection for production instances
- Use encrypted EBS volumes with customer-managed KMS keys for sensitive data
