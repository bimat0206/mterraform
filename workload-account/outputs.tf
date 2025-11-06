# -----------------------------------------------------------------------------
# Key Pair Outputs - Linux
# -----------------------------------------------------------------------------
output "keypair_linux_name" {
  description = "Linux key pair name (if created)"
  value       = var.create_keypair_linux ? module.keypair_linux[0].key_pair_name : null
}

output "keypair_linux_secret_arn" {
  description = "ARN of the secret containing Linux private key (if created)"
  value       = var.create_keypair_linux ? module.keypair_linux[0].secret_arn : null
}

output "keypair_linux_secret_name" {
  description = "Name of the secret containing Linux private key (if created)"
  value       = var.create_keypair_linux ? module.keypair_linux[0].secret_name : null
}

output "keypair_linux_retrieve_command" {
  description = "Command to retrieve Linux private key from Secrets Manager"
  value       = var.create_keypair_linux ? module.keypair_linux[0].retrieve_secret_command : null
}

# -----------------------------------------------------------------------------
# Key Pair Outputs - Windows
# -----------------------------------------------------------------------------
output "keypair_windows_name" {
  description = "Windows key pair name (if created)"
  value       = var.create_keypair_windows ? module.keypair_windows[0].key_pair_name : null
}

output "keypair_windows_secret_arn" {
  description = "ARN of the secret containing Windows private key (if created)"
  value       = var.create_keypair_windows ? module.keypair_windows[0].secret_arn : null
}

output "keypair_windows_secret_name" {
  description = "Name of the secret containing Windows private key (if created)"
  value       = var.create_keypair_windows ? module.keypair_windows[0].secret_name : null
}

output "keypair_windows_retrieve_command" {
  description = "Command to retrieve Windows private key from Secrets Manager"
  value       = var.create_keypair_windows ? module.keypair_windows[0].retrieve_secret_command : null
}

output "keypair_windows_decrypt_password_command" {
  description = "Command to decrypt Windows password using private key from Secrets Manager"
  value       = var.create_keypair_windows ? module.keypair_windows[0].decrypt_windows_password_command : null
}

# -----------------------------------------------------------------------------
# EC2 Linux Outputs
# -----------------------------------------------------------------------------
output "ec2_linux_instance_id" {
  description = "The ID of the Linux EC2 instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].instance_id : null
}

output "ec2_linux_instance_name" {
  description = "The name of the Linux EC2 instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].instance_name : null
}

output "ec2_linux_private_ip" {
  description = "The private IP of the Linux EC2 instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].private_ip : null
}

output "ec2_linux_public_ip" {
  description = "The public IP of the Linux EC2 instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].public_ip : null
}

output "ec2_linux_security_group_id" {
  description = "The security group ID of the Linux EC2 instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].security_group_id : null
}

output "ec2_linux_ssh_command" {
  description = "SSH connection command for Linux instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].ssh_connection_command : null
}

output "ec2_linux_ssm_command" {
  description = "SSM Session Manager command for Linux instance (if enabled)"
  value       = var.ec2_linux_enabled ? module.ec2_linux[0].ssm_session_command : null
}

# -----------------------------------------------------------------------------
# EC2 Windows Outputs
# -----------------------------------------------------------------------------
output "ec2_windows_instance_id" {
  description = "The ID of the Windows EC2 instance (if enabled)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].instance_id : null
}

output "ec2_windows_instance_name" {
  description = "The name of the Windows EC2 instance (if enabled)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].instance_name : null
}

output "ec2_windows_private_ip" {
  description = "The private IP of the Windows EC2 instance (if enabled)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].private_ip : null
}

output "ec2_windows_public_ip" {
  description = "The public IP of the Windows EC2 instance (if enabled)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].public_ip : null
}

output "ec2_windows_security_group_id" {
  description = "The security group ID of the Windows EC2 instance (if enabled)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].security_group_id : null
}

output "ec2_windows_password_data" {
  description = "Encrypted Windows password (if enabled and get_password_data = true)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].password_data : null
  sensitive   = true
}

output "ec2_windows_rdp_command" {
  description = "Command to retrieve Windows password (if enabled)"
  value       = var.ec2_windows_enabled ? module.ec2_windows[0].rdp_connection_command : null
}
