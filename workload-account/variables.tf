# -----------------------------------------------------------------------------
# General configuration
# -----------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS region where resources will be created"
}

# -----------------------------------------------------------------------------
# Naming convention inputs
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming (e.g., 'tsk')"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'prod', 'staging')"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., 'app', 'platform')"
}

# -----------------------------------------------------------------------------
# Tagging
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# Network Configuration (from Network Account)
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID from network account (use remote state or data source)"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs from network account"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs from network account"
}

# -----------------------------------------------------------------------------
# Key Pair Configuration
# -----------------------------------------------------------------------------
variable "create_keypair_linux" {
  type        = bool
  default     = false
  description = "Create EC2 key pair for Linux instances"
}

variable "create_keypair_windows" {
  type        = bool
  default     = false
  description = "Create EC2 key pair for Windows instances"
}

variable "keypair_algorithm" {
  type        = string
  default     = "RSA"
  description = "Algorithm for key pair generation (RSA, ECDSA, ED25519)"
}

variable "keypair_rsa_bits" {
  type        = number
  default     = 4096
  description = "RSA key size (2048 or 4096)"
}

variable "keypair_store_in_secretsmanager" {
  type        = bool
  default     = true
  description = "Store private keys in AWS Secrets Manager"
}

variable "keypair_secret_recovery_window" {
  type        = number
  default     = 30
  description = "Recovery window for deleted secrets (7-30 days)"
}

variable "keypair_kms_key_id" {
  type        = string
  default     = ""
  description = "Custom KMS key ID for secret encryption (empty = AWS managed key)"
}

# Use existing key pair names instead of creating new ones
variable "ec2_linux_existing_key_name" {
  type        = string
  default     = ""
  description = "Existing key pair name for Linux instance (if not creating new keypair)"
}

variable "ec2_windows_existing_key_name" {
  type        = string
  default     = ""
  description = "Existing key pair name for Windows instance (if not creating new keypair)"
}

# -----------------------------------------------------------------------------
# EC2 Linux Configuration
# -----------------------------------------------------------------------------
variable "ec2_linux_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Linux EC2 instance"
}

variable "ec2_linux_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance type for Linux EC2"
}

variable "ec2_linux_ami_id" {
  type        = string
  default     = ""
  description = "AMI ID for Linux (empty = auto-discover Amazon Linux 2023)"
}

variable "ec2_linux_key_name" {
  type        = string
  default     = ""
  description = "EC2 key pair name for SSH access to Linux instance"
}

variable "ec2_linux_associate_public_ip" {
  type        = bool
  default     = false
  description = "Associate public IP with Linux instance"
}

variable "ec2_linux_user_data" {
  type        = string
  default     = ""
  description = "User data script for Linux instance"
}

variable "ec2_linux_create_iam_profile" {
  type        = bool
  default     = true
  description = "Create IAM instance profile for Linux instance"
}

variable "ec2_linux_security_group_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH from VPC"
    }
  ]
  description = "Security group ingress rules for Linux instance"
}

variable "ec2_linux_root_volume_size" {
  type        = number
  default     = 20
  description = "Root volume size in GB for Linux instance"
}

variable "ec2_linux_monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed monitoring for Linux instance"
}

# -----------------------------------------------------------------------------
# EC2 Windows Configuration
# -----------------------------------------------------------------------------
variable "ec2_windows_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Windows EC2 instance"
}

variable "ec2_windows_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for Windows EC2 (minimum t3.medium recommended)"
}

variable "ec2_windows_ami_id" {
  type        = string
  default     = ""
  description = "AMI ID for Windows (empty = auto-discover Windows Server 2022)"
}

variable "ec2_windows_key_name" {
  type        = string
  default     = ""
  description = "EC2 key pair name for Windows instance (for password retrieval)"
}

variable "ec2_windows_associate_public_ip" {
  type        = bool
  default     = false
  description = "Associate public IP with Windows instance"
}

variable "ec2_windows_get_password_data" {
  type        = bool
  default     = false
  description = "Retrieve Windows administrator password"
}

variable "ec2_windows_user_data" {
  type        = string
  default     = ""
  description = "User data PowerShell script for Windows instance"
}

variable "ec2_windows_create_iam_profile" {
  type        = bool
  default     = true
  description = "Create IAM instance profile for Windows instance"
}

variable "ec2_windows_security_group_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "RDP from VPC"
    },
    {
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "WinRM from VPC"
    }
  ]
  description = "Security group ingress rules for Windows instance"
}

variable "ec2_windows_root_volume_size" {
  type        = number
  default     = 50
  description = "Root volume size in GB for Windows instance"
}

variable "ec2_windows_monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed monitoring for Windows instance"
}
