# -----------------------------------------------------------------------------
# Instance Outputs
# -----------------------------------------------------------------------------
output "instance_id" {
  description = "The ID of the Windows EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "The ARN of the Windows EC2 instance"
  value       = aws_instance.this.arn
}

output "instance_name" {
  description = "The name of the Windows EC2 instance"
  value       = local.name
}

output "instance_state" {
  description = "The state of the instance"
  value       = aws_instance.this.instance_state
}

output "instance_type" {
  description = "The instance type"
  value       = aws_instance.this.instance_type
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = aws_instance.this.availability_zone
}

# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------
output "private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "private_dns" {
  description = "The private DNS name of the instance"
  value       = aws_instance.this.private_dns
}

output "public_ip" {
  description = "The public IP address of the instance (if associated)"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "The public DNS name of the instance (if associated)"
  value       = aws_instance.this.public_dns
}

output "subnet_id" {
  description = "The subnet ID where the instance is launched"
  value       = aws_instance.this.subnet_id
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------
output "security_group_id" {
  description = "The ID of the security group (if created)"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group (if created)"
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

output "security_group_name" {
  description = "The name of the security group (if created)"
  value       = var.create_security_group ? aws_security_group.this[0].name : null
}

output "security_group_ids" {
  description = "List of all security group IDs attached to the instance"
  value       = local.security_group_ids
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------
output "iam_role_name" {
  description = "The name of the IAM role (if created)"
  value       = var.create_iam_instance_profile ? aws_iam_role.this[0].name : null
}

output "iam_role_arn" {
  description = "The ARN of the IAM role (if created)"
  value       = var.create_iam_instance_profile ? aws_iam_role.this[0].arn : null
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile (if created)"
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : null
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile (if created)"
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Windows-Specific Outputs
# -----------------------------------------------------------------------------
output "password_data" {
  description = "The encrypted Windows administrator password (if get_password_data = true)"
  value       = var.get_password_data ? aws_instance.this.password_data : null
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Storage Outputs
# -----------------------------------------------------------------------------
output "root_block_device_volume_id" {
  description = "The volume ID of the root block device"
  value       = aws_instance.this.root_block_device[0].volume_id
}

output "ebs_block_device_volume_ids" {
  description = "List of volume IDs of additional EBS block devices"
  value       = [for device in aws_instance.this.ebs_block_device : device.volume_id]
}

# -----------------------------------------------------------------------------
# AMI Outputs
# -----------------------------------------------------------------------------
output "ami_id" {
  description = "The AMI ID used for the instance"
  value       = local.ami_id
}

output "ami_name" {
  description = "The AMI name used for the instance (if auto-discovered)"
  value       = var.ami_id == "" ? data.aws_ami.windows[0].name : null
}

# -----------------------------------------------------------------------------
# Connection Information
# -----------------------------------------------------------------------------
output "rdp_connection_command" {
  description = "Command to retrieve Windows password (requires private key)"
  value       = var.get_password_data && var.key_name != "" ? "terraform output -raw password_data | base64 -d | openssl rsautl -decrypt -inkey /path/to/${var.key_name}.pem" : "N/A - get_password_data not enabled or key_name not specified"
}

output "winrm_connection_info" {
  description = "Information for WinRM connection"
  value = {
    host = var.associate_public_ip_address ? aws_instance.this.public_ip : aws_instance.this.private_ip
    port = 5985
    https_port = 5986
  }
}
