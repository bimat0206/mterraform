# EC2 Linux Module

Terraform module for deploying Linux EC2 instances with comprehensive configuration options including security groups, IAM roles, EBS volumes, and SSH access.

## Features

- **Automatic AMI Selection**: Auto-discovers latest Amazon Linux 2023 AMI or use custom AMI
- **SSH Support**: Key-based SSH access with configurable security groups
- **SSM Integration**: AWS Systems Manager Session Manager support
- **Security Group Management**: Auto-created security group with configurable rules
- **IAM Integration**: Optional IAM instance profile with SSM support
- **Storage Flexibility**: Configurable root volume and additional EBS volumes
- **IMDSv2**: Enforced by default for enhanced security
- **Dynamic Naming**: Consistent resource naming based on organizational standards
- **Encryption**: EBS encryption enabled by default
- **IPv6 Support**: Optional IPv6 address assignment
- **Monitoring**: Optional detailed monitoring
- **Termination Protection**: Configurable instance and stop protection

## Cost Information

**EC2 Instance Costs (ap-southeast-1):**
- t3.micro: ~$8.47/month (2 vCPU, 1 GiB RAM) - Free tier eligible
- t3.small: ~$16.94/month (2 vCPU, 2 GiB RAM)
- t3.medium: ~$33.87/month (2 vCPU, 4 GiB RAM)
- t3.large: ~$67.74/month (2 vCPU, 8 GiB RAM)
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
| aws_ami.linux | data source |
| aws_region.current | data source |

## Usage Examples

### Basic Linux Server

```hcl
module "linux_server" {
  source = "../modules/ec2-linux"

  # Naming
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Instance
  instance_type = "t3.micro"
  key_name      = "my-keypair"

  tags = {}
}
```

### Linux Server with SSH Access

```hcl
module "linux_ssh" {
  source = "../modules/ec2-linux"

  # Naming
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  service     = "bastion"
  identifier  = "01"

  # Network
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true

  # Instance
  instance_type = "t3.micro"
  key_name      = "my-keypair"

  # Security Group - SSH only from specific IP
  create_security_group = true
  security_group_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "SSH from office"
    }
  ]

  tags = {}
}
```

### Linux Server with SSM (no SSH)

```hcl
module "linux_ssm" {
  source = "../modules/ec2-linux"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Instance
  instance_type = "t3.small"

  # IAM - Enable SSM for secure access without SSH
  create_iam_instance_profile = true
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  # Security Group - No inbound access (SSM uses outbound)
  create_security_group = true
  security_group_ingress_rules = []

  # Protection
  disable_api_termination = true

  tags = {}
}
```

### Linux Web Server with User Data

```hcl
module "linux_web" {
  source = "../modules/ec2-linux"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"
  identifier  = "01"

  # Network
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true

  # Instance
  instance_type = "t3.small"

  # User Data - Install and configure Nginx
  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Hello from $(hostname)" > /usr/share/nginx/html/index.html
  EOT

  # IAM
  create_iam_instance_profile = true

  # Security Group
  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from anywhere"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "SSH from office"
    }
  ]

  tags = {}
}
```

### Linux Server with Additional Storage

```hcl
module "linux_storage" {
  source = "../modules/ec2-linux"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "data"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Instance
  instance_type = "m5.large"

  # Root Volume
  root_block_device = {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
    iops        = 3000
    throughput  = 125
  }

  # Additional Data Volumes
  ebs_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 500
      encrypted   = true
      iops        = 5000
      throughput  = 250
    },
    {
      device_name = "/dev/sdg"
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

### Ubuntu Server

```hcl
module "ubuntu_server" {
  source = "../modules/ec2-linux"

  # Naming
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  identifier  = "01"

  # Network
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Ubuntu 22.04 LTS AMI
  ami_owner       = "099720109477"  # Canonical
  ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

  # Instance
  instance_type = "t3.micro"
  key_name      = "my-keypair"

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
| service | string | "" | Service name (defaults to 'ec2-linux') |
| identifier | string | "" | Resource identifier |

### Instance Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| instance_type | string | "t3.micro" | EC2 instance type |
| ami_id | string | "" | Custom AMI ID (empty = auto-discover) |
| ami_name_filter | string | "al2023-ami-2023*-x86_64" | AMI name filter |
| key_name | string | "" | EC2 key pair name |
| monitoring | bool | false | Enable detailed monitoring |
| disable_api_termination | bool | false | Enable termination protection |
| user_data | string | "" | Bash script for initialization |

### Network Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| vpc_id | string | - | VPC ID |
| subnet_id | string | - | Subnet ID |
| private_ip | string | "" | Static private IP (optional) |
| associate_public_ip_address | bool | false | Assign public IP |
| ipv6_address_count | number | 0 | Number of IPv6 addresses |

### Security Group

| Name | Type | Default | Description |
|------|------|---------|-------------|
| create_security_group | bool | true | Create security group |
| security_group_ids | list(string) | [] | Existing security group IDs |
| security_group_ingress_rules | list(object) | SSH | Ingress rules |

**Default Ingress Rules:**
- Port 22 (SSH) from 0.0.0.0/0

**Security Note**: Default rule allows SSH from anywhere. Restrict CIDR blocks in production.

### Storage Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| root_block_device | object | gp3, 20GB | Root volume config |
| ebs_block_devices | list(object) | [] | Additional EBS volumes |

**Root Block Device Defaults:**
- volume_type: gp3
- volume_size: 20 GB
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
| ipv6_addresses | IPv6 addresses |
| security_group_id | Security group ID |
| ssh_connection_command | SSH connection command |
| ssm_session_command | SSM Session Manager command |

## Linux Device Names

Linux recognizes EBS volumes with these device names:
- `/dev/sdf` through `/dev/sdp` for additional volumes
- Root volume is typically `/dev/sda` or `/dev/xvda` (auto-assigned)

## Security Best Practices

1. **SSH Access**: Restrict SSH (port 22) to known IP addresses
2. **Use SSM**: Prefer AWS Systems Manager Session Manager over SSH
3. **IMDSv2**: Enabled by default - do not disable
4. **Encryption**: Enable EBS encryption with KMS keys
5. **IAM Roles**: Use instance profiles instead of embedding credentials
6. **Termination Protection**: Enable in production environments
7. **Security Groups**: Follow principle of least privilege
8. **Monitoring**: Enable CloudWatch detailed monitoring in production
9. **OS Updates**: Regularly apply security patches
10. **Bastion Hosts**: Use dedicated bastion hosts for SSH access

## Troubleshooting

### Cannot connect via SSH

1. Check security group allows port 22 from your IP
2. Verify instance has public IP (if accessing from internet)
3. Ensure key pair (.pem file) has correct permissions: `chmod 400 keypair.pem`
4. Check Network ACLs on subnet
5. Verify correct username (ec2-user for Amazon Linux, ubuntu for Ubuntu)

### SSM Session Manager not working

1. Verify IAM instance profile has `AmazonSSMManagedInstanceCore` policy
2. Ensure instance has outbound internet access or VPC endpoints for SSM
3. Check SSM agent is running: `sudo systemctl status amazon-ssm-agent`
4. Verify instance appears in Systems Manager Fleet Manager
5. Check IAM user/role has SSM permissions

### Instance fails to launch

1. Check if AMI ID is valid and available in your region
2. Verify subnet has available IP addresses
3. Ensure instance type is available in the selected AZ
4. Check service quotas for EC2 instances
5. Review CloudWatch Logs for initialization errors

### User data script not executing

1. Check `/var/log/cloud-init-output.log` for script output
2. Verify script has correct shebang: `#!/bin/bash`
3. Ensure script has no syntax errors
4. Check if `user_data_replace_on_change = true` if updating

## AMI Versions

By default, this module uses the latest **Amazon Linux 2023** AMI. To use a different distribution:

```hcl
# Amazon Linux 2
ami_name_filter = "amzn2-ami-hvm-*-x86_64-gp2"

# Ubuntu 22.04 LTS
ami_owner       = "099720109477"  # Canonical
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

# Ubuntu 20.04 LTS
ami_owner       = "099720109477"
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"

# Red Hat Enterprise Linux 9
ami_owner       = "309956199498"  # Red Hat
ami_name_filter = "RHEL-9*_HVM-*-x86_64-*"

# Debian 12
ami_owner       = "136693071363"  # Debian
ami_name_filter = "debian-12-amd64-*"
```

## Default Usernames by Distribution

| Distribution | Default Username |
|--------------|------------------|
| Amazon Linux 2023 | ec2-user |
| Amazon Linux 2 | ec2-user |
| Ubuntu | ubuntu |
| Red Hat | ec2-user |
| Debian | admin |
| CentOS | centos |

## Related Modules

- `../vpc/` - VPC infrastructure
- `../ec2-windows/` - Windows EC2 instances
- `../alb/` - Application Load Balancer

## License

This module is provided as-is for use within your organization.
