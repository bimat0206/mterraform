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
