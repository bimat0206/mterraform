# EC2 Windows Module

Terraform module for deploying Windows Server EC2 instances with comprehensive configuration options including security groups, IAM roles, EBS volumes, and Windows-specific features.

## Features

- **Automatic AMI Selection**: Auto-discovers latest Windows Server AMI or use custom AMI
- **Windows Support**: RDP, WinRM, and password retrieval capabilities
- **Security Group Management**: Auto-created security group with configurable rules
- **IAM Integration**: Optional IAM instance profile with SSM support
- **Storage Flexibility**: Configurable root volume and additional EBS volumes
- **IMDSv2**: Enforced by default for enhanced security
- **Dynamic Naming**: Consistent resource naming based on organizational standards
- **Encryption**: EBS encryption enabled by default
- **Monitoring**: Optional detailed monitoring
- **Termination Protection**: Configurable instance and stop protection

## Cost Information

**EC2 Instance Costs (ap-southeast-1):**
- t3.medium: ~$34.94/month (2 vCPU, 4 GiB RAM)
- t3.large: ~$69.89/month (2 vCPU, 8 GiB RAM)
- m5.large: ~$93.44/month (2 vCPU, 8 GiB RAM)
- m5.xlarge: ~$186.88/month (4 vCPU, 16 GiB RAM)

**Storage Costs:**
- gp3: ~$0.092/GB-month (default)
- gp2: ~$0.115/GB-month
- io1/io2: ~$0.138/GB-month + IOPS charges

**Additional Costs:**
- Detailed monitoring: $2.10/instance/month
- Data transfer: Varies by region and volume

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| aws_instance.this | resource |
| aws_security_group.this | resource |
| aws_vpc_security_group_ingress_rule.this | resource |
| aws_vpc_security_group_egress_rule.this | resource |
| aws_iam_role.this | resource |
| aws_iam_role_policy_attachment.this | resource |
| aws_iam_instance_profile.this | resource |
| aws_ami.windows | data source |
| aws_region.current | data source |

## Usage Examples

### Basic Windows Server

```hcl
module "windows_server" {
  source = "../modules/ec2-windows"

  # Naming
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Instance
  instance_type = "t3.medium"
  key_name      = "my-keypair"

  tags = {}
}
```

### Windows Server with RDP Access

```hcl
module "windows_rdp" {
  source = "../modules/ec2-windows"

  # Naming
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  service     = "jump"
  identifier  = "01"

  # Network
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true

  # Instance
  instance_type     = "t3.medium"
  key_name          = "my-keypair"
  get_password_data = true  # Retrieve Windows password

  # Security Group - RDP only from specific IP
  create_security_group = true
  security_group_ingress_rules = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "RDP from office"
    }
  ]

  tags = {}
}
```

### Windows Server with SSM (no RDP)

```hcl
module "windows_ssm" {
  source = "../modules/ec2-windows"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Instance
  instance_type = "t3.large"

  # IAM - Enable SSM for secure access without RDP
  create_iam_instance_profile = true
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # Security Group - No inbound access (SSM uses outbound)
  create_security_group = true
  security_group_ingress_rules = []

  # Protection
  disable_api_termination = true

  tags = {}
}
```

### Windows Server with Additional Storage

```hcl
module "windows_storage" {
  source = "../modules/ec2-windows"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "data"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Instance
  instance_type = "m5.xlarge"

  # Root Volume
  root_block_device = {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
    iops        = 3000
    throughput  = 125
  }

  # Additional Data Volumes
  ebs_block_devices = [
    {
      device_name = "xvdf"
      volume_type = "gp3"
      volume_size = 500
      encrypted   = true
      iops        = 5000
      throughput  = 250
    },
    {
      device_name = "xvdg"
      volume_type = "gp3"
      volume_size = 1000
      encrypted   = true
      iops        = 10000
      throughput  = 500
    }
  ]

  # IAM
  create_iam_instance_profile = true

  tags = {}
}
```

### Windows Server with Custom AMI and User Data

```hcl
module "windows_custom" {
  source = "../modules/ec2-windows"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Custom AMI
  ami_id        = "ami-0123456789abcdef"
  instance_type = "t3.large"

  # User Data - PowerShell script
  user_data = <<-EOT
    <powershell>
    # Install IIS
    Install-WindowsFeature -name Web-Server -IncludeManagementTools

    # Configure application
    New-Item -Path "C:\webapp" -ItemType Directory
    Set-Content -Path "C:\webapp\index.html" -Value "Hello from Windows Server"

    # Start IIS
    Start-Service W3SVC
    </powershell>
  EOT

  # IAM
  create_iam_instance_profile = true

  tags = {}
}
```

## Variables

### Naming Convention

| Name | Type | Default | Description |
|------|------|---------|-------------|
| org_prefix | string | - | Organization prefix |
| environment | string | - | Environment name |
| workload | string | - | Workload name |
| service | string | "" | Service name (defaults to 'ec2-windows') |
| identifier | string | "" | Resource identifier |

### Instance Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| instance_type | string | "t3.medium" | EC2 instance type |
| ami_id | string | "" | Custom AMI ID (empty = auto-discover) |
| ami_name_filter | string | "Windows_Server-2022-English-Full-Base-*" | AMI name filter |
| key_name | string | "" | EC2 key pair name |
| monitoring | bool | false | Enable detailed monitoring |
| disable_api_termination | bool | false | Enable termination protection |
| get_password_data | bool | false | Retrieve Windows password |
| user_data | string | "" | PowerShell/batch script |

### Network Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| vpc_id | string | - | VPC ID |
| subnet_id | string | - | Subnet ID |
| private_ip | string | "" | Static private IP (optional) |
| associate_public_ip_address | bool | false | Assign public IP |

### Security Group

| Name | Type | Default | Description |
|------|------|---------|-------------|
| create_security_group | bool | true | Create security group |
| security_group_ids | list(string) | [] | Existing security group IDs |
| security_group_ingress_rules | list(object) | RDP + WinRM | Ingress rules |

**Default Ingress Rules:**
- Port 3389 (RDP) from 0.0.0.0/0
- Ports 5985-5986 (WinRM) from 0.0.0.0/0

**Security Note**: Default rules allow access from anywhere. Restrict CIDR blocks in production.

### Storage Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| root_block_device | object | gp3, 50GB | Root volume config |
| ebs_block_devices | list(object) | [] | Additional EBS volumes |

**Root Block Device Defaults:**
- volume_type: gp3
- volume_size: 50 GB
- iops: 3000
- throughput: 125 MB/s
- encrypted: true

### IAM Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| create_iam_instance_profile | bool | false | Create IAM profile |
| iam_role_policies | list(string) | ["AmazonSSMManagedInstanceCore"] | IAM policies |
| iam_instance_profile_arn | string | "" | Existing profile ARN |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | Instance ID |
| instance_arn | Instance ARN |
| instance_name | Instance name |
| private_ip | Private IP address |
| public_ip | Public IP address (if assigned) |
| security_group_id | Security group ID |
| password_data | Encrypted Windows password (sensitive) |
| rdp_connection_command | Command to decrypt password |
| winrm_connection_info | WinRM connection details |

## Windows Password Retrieval

To retrieve the Windows administrator password:

1. Enable password retrieval:
```hcl
key_name          = "my-keypair"
get_password_data = true
```

2. After deployment, decrypt the password:
```bash
terraform output -raw password_data | base64 -d | openssl rsautl -decrypt -inkey /path/to/my-keypair.pem
```

## Windows Device Names

Windows recognizes EBS volumes with these device names:
- `xvdf` through `xvdp` for additional volumes
- Root volume is typically `xvda` (auto-assigned)

## Security Best Practices

1. **RDP Access**: Restrict RDP (port 3389) to known IP addresses
2. **Use SSM**: Prefer AWS Systems Manager Session Manager over RDP
3. **IMDSv2**: Enabled by default - do not disable
4. **Encryption**: Enable EBS encryption with KMS keys
5. **IAM Roles**: Use instance profiles instead of embedding credentials
6. **Termination Protection**: Enable in production environments
7. **Security Groups**: Follow principle of least privilege
8. **Monitoring**: Enable CloudWatch detailed monitoring in production

## Troubleshooting

### Cannot connect via RDP

1. Check security group allows port 3389 from your IP
2. Verify instance has public IP (if accessing from internet)
3. Ensure Windows Firewall allows RDP
4. Check Network ACLs on subnet

### Cannot retrieve Windows password

1. Verify `get_password_data = true` is set
2. Ensure `key_name` is specified and corresponds to an EC2 key pair
3. Wait 3-5 minutes after instance launch for password to be available
4. Ensure you have the private key (.pem file)

### SSM Session Manager not working

1. Verify IAM instance profile has `AmazonSSMManagedInstanceCore` policy
2. Ensure instance has outbound internet access or VPC endpoints for SSM
3. Check SSM agent is running (pre-installed on Windows AMIs)
4. Verify instance appears in Systems Manager Fleet Manager

### Instance fails to launch

1. Check if AMI ID is valid and available in your region
2. Verify subnet has available IP addresses
3. Ensure instance type is available in the selected AZ
4. Check service quotas for EC2 instances

## AMI Versions

By default, this module uses the latest **Windows Server 2022 Base** AMI. To use a different version:

```hcl
# Windows Server 2019
ami_name_filter = "Windows_Server-2019-English-Full-Base-*"

# Windows Server 2016
ami_name_filter = "Windows_Server-2016-English-Full-Base-*"

# SQL Server editions
ami_name_filter = "Windows_Server-2022-English-Full-SQL_2022_Standard-*"
```

## Related Modules

- `../vpc/` - VPC infrastructure
- `../ec2-linux/` - Linux EC2 instances

## License

This module is provided as-is for use within your organization.
