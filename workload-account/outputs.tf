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

# -----------------------------------------------------------------------------
# RDS PostgreSQL Outputs
# -----------------------------------------------------------------------------
output "rds_postgresql_endpoint" {
  description = "PostgreSQL RDS endpoint (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].db_instance_endpoint : null
}

output "rds_postgresql_address" {
  description = "PostgreSQL RDS address (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].db_instance_address : null
}

output "rds_postgresql_port" {
  description = "PostgreSQL RDS port (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].db_instance_port : null
}

output "rds_postgresql_database_name" {
  description = "PostgreSQL database name (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].db_instance_name : null
}

output "rds_postgresql_connection_secret_arn" {
  description = "ARN of the complete connection secret with username, password, endpoint, port, and database name (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].connection_secret_arn : null
}

output "rds_postgresql_connection_secret_name" {
  description = "Name of the complete connection secret (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].connection_secret_name : null
}

output "rds_postgresql_retrieve_connection_info_command" {
  description = "Command to retrieve complete PostgreSQL connection information from Secrets Manager (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].retrieve_connection_info_command : null
}

output "rds_postgresql_connection_command" {
  description = "psql command to connect to PostgreSQL (if enabled)"
  value       = var.rds_postgresql_enabled ? module.rds_postgresql[0].psql_command : null
}

# -----------------------------------------------------------------------------
# RDS MySQL Outputs
# -----------------------------------------------------------------------------
output "rds_mysql_endpoint" {
  description = "MySQL RDS endpoint (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].db_instance_endpoint : null
}

output "rds_mysql_address" {
  description = "MySQL RDS address (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].db_instance_address : null
}

output "rds_mysql_port" {
  description = "MySQL RDS port (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].db_instance_port : null
}

output "rds_mysql_database_name" {
  description = "MySQL database name (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].db_instance_name : null
}

output "rds_mysql_connection_secret_arn" {
  description = "ARN of the complete connection secret with username, password, endpoint, port, and database name (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].connection_secret_arn : null
}

output "rds_mysql_connection_secret_name" {
  description = "Name of the complete connection secret (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].connection_secret_name : null
}

output "rds_mysql_retrieve_connection_info_command" {
  description = "Command to retrieve complete MySQL connection information from Secrets Manager (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].retrieve_connection_info_command : null
}

output "rds_mysql_connection_command" {
  description = "mysql command to connect to MySQL (if enabled)"
  value       = var.rds_mysql_enabled ? module.rds_mysql[0].mysql_command : null
}

# -----------------------------------------------------------------------------
# RDS SQL Server Outputs
# -----------------------------------------------------------------------------
output "rds_sqlserver_endpoint" {
  description = "SQL Server RDS endpoint (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].db_instance_endpoint : null
}

output "rds_sqlserver_address" {
  description = "SQL Server RDS address (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].db_instance_address : null
}

output "rds_sqlserver_port" {
  description = "SQL Server RDS port (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].db_instance_port : null
}

output "rds_sqlserver_database_name" {
  description = "SQL Server database name (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].db_instance_name : null
}

output "rds_sqlserver_connection_secret_arn" {
  description = "ARN of the complete connection secret with username, password, endpoint, port, and database name (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].connection_secret_arn : null
}

output "rds_sqlserver_connection_secret_name" {
  description = "Name of the complete connection secret (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].connection_secret_name : null
}

output "rds_sqlserver_retrieve_connection_info_command" {
  description = "Command to retrieve complete SQL Server connection information from Secrets Manager (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].retrieve_connection_info_command : null
}

output "rds_sqlserver_connection_command" {
  description = "sqlcmd command to connect to SQL Server (if enabled)"
  value       = var.rds_sqlserver_enabled ? module.rds_sqlserver[0].sqlcmd_command : null
}

# -----------------------------------------------------------------------------
# EKS Outputs
# -----------------------------------------------------------------------------
output "eks_cluster_id" {
  description = "EKS cluster ID/name (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_id : null
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_endpoint : null
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_arn : null
}

output "eks_cluster_version" {
  description = "Kubernetes version (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_version : null
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_security_group_id : null
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID (if enabled)"
  value       = var.eks_enabled ? module.eks[0].node_security_group_id : null
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA (if enabled)"
  value       = var.eks_enabled ? module.eks[0].oidc_provider_arn : null
}

output "eks_cluster_iam_role_arn" {
  description = "EKS cluster IAM role ARN (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_iam_role_arn : null
}

output "eks_node_group_iam_role_arn" {
  description = "EKS node group IAM role ARN (if enabled)"
  value       = var.eks_enabled ? module.eks[0].node_group_iam_role_arn : null
}

output "eks_ebs_csi_driver_iam_role_arn" {
  description = "EBS CSI driver IAM role ARN (if enabled)"
  value       = var.eks_enabled ? module.eks[0].ebs_csi_driver_iam_role_arn : null
}

output "eks_aws_load_balancer_controller_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM role ARN (if enabled)"
  value       = var.eks_enabled ? module.eks[0].aws_load_balancer_controller_iam_role_arn : null
}

output "eks_cluster_log_group_name" {
  description = "CloudWatch log group name for EKS control plane logs (if enabled)"
  value       = var.eks_enabled ? module.eks[0].cluster_log_group_name : null
}

output "eks_container_insights_log_group_names" {
  description = "Container Insights log group names (if enabled)"
  value       = var.eks_enabled ? module.eks[0].container_insights_log_group_names : null
}

output "eks_kubeconfig_command" {
  description = "Command to configure kubectl (if enabled)"
  value       = var.eks_enabled ? module.eks[0].kubeconfig_command : null
}

output "eks_node_group_ids" {
  description = "Map of node group IDs (if enabled)"
  value       = var.eks_enabled ? module.eks[0].node_group_ids : null
}

output "eks_node_group_status" {
  description = "Map of node group statuses (if enabled)"
  value       = var.eks_enabled ? module.eks[0].node_group_status : null
}

output "eks_enabled_log_types" {
  description = "List of enabled EKS control plane log types (if enabled)"
  value       = var.eks_enabled ? module.eks[0].enabled_log_types : null
}

output "eks_addons_enabled" {
  description = "Map of enabled EKS add-ons (if enabled)"
  value       = var.eks_enabled ? module.eks[0].addons_enabled : null
}

output "eks_view_cluster_logs_command" {
  description = "Command to view EKS control plane logs (if enabled)"
  value       = var.eks_enabled ? module.eks[0].view_cluster_logs_command : null
}

output "eks_view_container_insights_command" {
  description = "Command to view Container Insights logs (if enabled)"
  value       = var.eks_enabled ? module.eks[0].view_container_insights_command : null
}
