# -----------------------------------------------------------------------------
# Naming Convention Variables
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod, staging)"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., app, platform)"
}

variable "service" {
  type        = string
  default     = ""
  description = "Service name (e.g., web, api). If empty, will use 'ec2-linux'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# Instance Configuration
# -----------------------------------------------------------------------------
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "AMI ID for Linux. If empty, will use latest Amazon Linux 2023"
}

variable "ami_owner" {
  type        = string
  default     = "amazon"
  description = "Owner of the AMI (default: amazon)"
}

variable "ami_name_filter" {
  type        = string
  default     = "al2023-ami-2023*-x86_64"
  description = "AMI name filter pattern for automatic AMI lookup"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "EC2 key pair name for SSH access"
}

variable "monitoring" {
  type        = bool
  default     = false
  description = "Enable detailed monitoring (additional cost)"
}

variable "disable_api_termination" {
  type        = bool
  default     = false
  description = "Enable termination protection"
}

variable "disable_api_stop" {
  type        = bool
  default     = false
  description = "Enable stop protection"
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  default     = "stop"
  description = "Shutdown behavior (stop or terminate)"
  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Must be either 'stop' or 'terminate'."
  }
}

variable "user_data" {
  type        = string
  default     = ""
  description = "User data script for instance initialization (bash script)"
}

variable "user_data_replace_on_change" {
  type        = bool
  default     = false
  description = "Replace instance when user_data changes"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "Subnet ID where the instance will be launched"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group creation"
}

variable "private_ip" {
  type        = string
  default     = ""
  description = "Private IP address (leave empty for automatic assignment)"
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IP address with the instance"
}

variable "source_dest_check" {
  type        = bool
  default     = true
  description = "Enable source/destination checking"
}

variable "ipv6_address_count" {
  type        = number
  default     = 0
  description = "Number of IPv6 addresses to assign"
}

# -----------------------------------------------------------------------------
# Security Group Configuration
# -----------------------------------------------------------------------------
variable "create_security_group" {
  type        = bool
  default     = true
  description = "Create a security group for the instance"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of existing security group IDs (used if create_security_group = false)"
}

variable "security_group_ingress_rules" {
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
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH from anywhere"
    }
  ]
  description = "List of ingress rules for the security group"
}

variable "security_group_egress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks for egress traffic"
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------
variable "root_block_device" {
  type = object({
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 20)
    iops                  = optional(number, 3000)
    throughput            = optional(number, 125)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, "")
    delete_on_termination = optional(bool, true)
  })
  default = {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }
  description = "Root block device configuration"
}

variable "ebs_block_devices" {
  type = list(object({
    device_name           = string
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 100)
    iops                  = optional(number, 3000)
    throughput            = optional(number, 125)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, "")
    delete_on_termination = optional(bool, true)
  }))
  default     = []
  description = "Additional EBS volumes to attach to the instance"
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------
variable "create_iam_instance_profile" {
  type        = bool
  default     = false
  description = "Create an IAM instance profile for the instance"
}

variable "iam_role_name" {
  type        = string
  default     = ""
  description = "Custom IAM role name (if empty, will be auto-generated)"
}

variable "iam_role_policies" {
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  description = "List of IAM policy ARNs to attach to the role"
}

variable "iam_instance_profile_arn" {
  type        = string
  default     = ""
  description = "Existing IAM instance profile ARN (used if create_iam_instance_profile = false)"
}

# -----------------------------------------------------------------------------
# Metadata Options Configuration
# -----------------------------------------------------------------------------
variable "metadata_options" {
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, "enabled")
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  description = "Instance metadata options (IMDSv2 configuration)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the instance"
}
