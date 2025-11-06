# Changelog - EC2 Linux Module

All notable changes to the EC2 Linux module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of EC2 Linux module
- Automatic AMI discovery for Linux distributions (default: Amazon Linux 2023)
- Support for custom AMI ID
- Configurable instance type with t3.micro default (Free tier eligible)
- EC2 key pair integration for SSH access
- User data support for bash scripts
- Auto-created security group with SSH (22) access
- Configurable security group ingress/egress rules
- Optional IAM instance profile with SSM support
- Configurable root EBS volume (gp3, 20GB default, encrypted)
- Support for additional EBS volumes with flexible configuration
- IMDSv2 enforced by default for enhanced security
- Instance metadata tags support
- IPv6 address support
- Detailed monitoring option
- Instance termination and stop protection
- Dynamic naming based on organizational standards
- Comprehensive outputs including SSH and SSM connection information

### Features
- **Linux Support**: Full Linux distribution integration
  - SSH access (port 22)
  - Bash user data scripts
  - Multiple distribution support (Amazon Linux, Ubuntu, RHEL, Debian)
  - SSM Session Manager integration
- **Security**: Security-first configuration
  - Auto-created security group
  - IMDSv2 enforced by default
  - EBS encryption enabled by default
  - IAM instance profile support
  - SSM agent pre-installed on Amazon Linux
- **Storage**: Flexible EBS configuration
  - gp3 volumes by default (cost-optimized)
  - Configurable IOPS and throughput
  - KMS encryption support
  - Multiple additional volumes
- **Networking**: Comprehensive network options
  - Public or private subnet deployment
  - Static private IP support
  - Public IP association option
  - IPv6 support
  - Source/destination checking control
- **High Availability**: Protection features
  - Termination protection
  - Stop protection
  - Configurable shutdown behavior

### Cost Information
- **t3.micro**: ~$8.47/month (2 vCPU, 1 GiB RAM) - **Free tier eligible**
- **t3.small**: ~$16.94/month (2 vCPU, 2 GiB RAM)
- **t3.medium**: ~$33.87/month (2 vCPU, 4 GiB RAM)
- **t3.large**: ~$67.74/month (2 vCPU, 8 GiB RAM)
- **Storage (gp3)**: ~$0.092/GB-month
- **Detailed monitoring**: $2.10/instance/month (optional)

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with at least one subnet
- EC2 key pair (optional, for SSH access)

### Use Cases
- Web servers (Nginx, Apache)
- Application servers (Node.js, Python, Java)
- Bastion/Jump hosts for SSH access
- Development and testing environments
- Database servers (MySQL, PostgreSQL)
- Container hosts (Docker)
- CI/CD build agents
- Microservices
- API backends

### Default Configuration
- **Instance Type**: t3.micro (Free tier eligible)
- **AMI**: Latest Amazon Linux 2023 (auto-discovered)
- **Root Volume**: gp3, 20 GB, encrypted
- **Security Group**: SSH (22) from 0.0.0.0/0
- **IAM Policies**: AmazonSSMManagedInstanceCore (if IAM profile created)
- **IMDSv2**: Required (http_tokens = required)
- **Monitoring**: Basic (detailed monitoring disabled by default)
- **IPv6**: Disabled (ipv6_address_count = 0)

### Security Considerations
- Default security group rule allows SSH from anywhere (0.0.0.0/0)
- **Production Recommendation**: Restrict CIDR blocks to known IPs
- **Best Practice**: Use AWS Systems Manager Session Manager instead of SSH
- IMDSv2 is enforced by default
- EBS encryption is enabled by default
- Consider using private subnets with VPN/Direct Connect
- Regularly apply OS security patches

### Linux-Specific Features
- **SSH Access**: Standard key-based authentication with EC2 key pairs
- **User Data**: Bash scripts for automated configuration
- **Device Naming**: Use `/dev/sdf` through `/dev/sdp` for additional volumes
- **AMI Filters**: Default filter finds latest Amazon Linux 2023
- **SSM Integration**: Pre-installed on Amazon Linux distributions

### Supported Distributions
- Amazon Linux 2023 (default)
- Amazon Linux 2
- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS
- Red Hat Enterprise Linux 9
- Debian 12
- CentOS Stream

### Example Configurations

**Basic Linux Server:**
```hcl
module "linux" {
  source = "../modules/ec2-linux"

  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  instance_type = "t3.micro"
  key_name      = "my-keypair"

  tags = {}
}
```

**Linux Bastion Host:**
```hcl
module "bastion" {
  source = "../modules/ec2-linux"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "bastion"

  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true

  instance_type = "t3.micro"
  key_name      = "my-keypair"

  security_group_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "SSH from office"
    }
  ]

  disable_api_termination = true

  tags = {}
}
```

**Linux Web Server:**
```hcl
module "web_server" {
  source = "../modules/ec2-linux"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"

  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true

  instance_type = "t3.small"

  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOT

  create_iam_instance_profile = true

  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]

  tags = {}
}
```

**Linux with SSM (no SSH):**
```hcl
module "linux_ssm" {
  source = "../modules/ec2-linux"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  instance_type = "t3.small"

  create_iam_instance_profile = true
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  security_group_ingress_rules = []  # No inbound access

  tags = {}
}
```

### Documentation
- Comprehensive README with usage examples
- Multiple deployment scenarios (basic, bastion, web server, SSM)
- Cost breakdown and optimization tips
- Security best practices
- Troubleshooting guide
- Distribution-specific information
- Default username table by distribution

### Outputs
- Instance: ID, ARN, name, state, type, AZ
- Network: Private/public IP and DNS, IPv6 addresses
- Security: Security group ID, ARN, name
- IAM: Role and instance profile details
- Storage: Root and EBS volume IDs
- Connection: SSH and SSM commands

### Integration
- Fully compatible with VPC module
- Supports VPC endpoints for SSM
- IAM integration for AWS service access
- CloudWatch integration for monitoring
- Target group attachment for ALB

### Known Limitations
- SSH access requires EC2 key pair
- Default security group rule is permissive (restrict in production)
- User data scripts execute only on first boot (unless `user_data_replace_on_change = true`)
- IPv6 support requires IPv6-enabled VPC and subnet

### Migration Notes
- This is the initial release (no migration needed)
- Follow organizational naming convention standards
- Ensure VPC and subnet exist before deployment
- Create EC2 key pair if SSH access is needed
- For Ubuntu, use username 'ubuntu' instead of 'ec2-user'

### Related Modules
- `../vpc/` - VPC infrastructure for EC2 deployment
- `../ec2-windows/` - Windows EC2 instances
- `../alb/` - Application Load Balancer for web servers
- `../vpc-endpoint-interface/` - VPC endpoints for SSM access

### Default Usernames
- Amazon Linux: `ec2-user`
- Ubuntu: `ubuntu`
- Red Hat: `ec2-user`
- Debian: `admin`
- CentOS: `centos`

### Best Practices
- Use t3 instances for variable workloads (burstable performance)
- Enable termination protection for production
- Use SSM Session Manager instead of SSH for better security
- Apply security patches regularly
- Use private subnets for non-public-facing instances
- Enable detailed monitoring for production workloads
- Use encrypted EBS volumes with customer-managed KMS keys
- Implement proper backup strategies (AWS Backup or EBS snapshots)
- Use Auto Scaling Groups for high availability
- Tag instances appropriately for cost allocation

### Notes
- t3.micro is Free tier eligible (750 hours/month for 12 months)
- Amazon Linux 2023 provides quarterly releases with 5-year support
- SSM Session Manager requires no inbound ports open
- Consider using EC2 Image Builder for custom AMIs
- Use CloudWatch Logs for centralized log management
