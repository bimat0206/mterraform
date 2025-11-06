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

output "eks_fargate_profile_ids" {
  description = "Map of Fargate profile IDs (if enabled)"
  value       = var.eks_enabled ? module.eks[0].fargate_profile_ids : null
}

output "eks_fargate_profile_arns" {
  description = "Map of Fargate profile ARNs (if enabled)"
  value       = var.eks_enabled ? module.eks[0].fargate_profile_arns : null
}

output "eks_fargate_profile_status" {
  description = "Map of Fargate profile statuses (if enabled)"
  value       = var.eks_enabled ? module.eks[0].fargate_profile_status : null
}

output "eks_fargate_profile_role_arn" {
  description = "ARN of Fargate profile IAM role (if enabled)"
  value       = var.eks_enabled ? module.eks[0].fargate_profile_role_arn : null
}

output "eks_fargate_enabled" {
  description = "Whether Fargate profiles are enabled (if EKS enabled)"
  value       = var.eks_enabled ? module.eks[0].fargate_enabled : null
}

# -----------------------------------------------------------------------------
# ECR Outputs
# -----------------------------------------------------------------------------
output "ecr_repository_arns" {
  description = "Map of ECR repository ARNs (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].repository_arns : null
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].repository_urls : null
}

output "ecr_repository_names" {
  description = "Map of ECR repository names (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].repository_names : null
}

output "ecr_registry_id" {
  description = "ECR registry ID (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].registry_id : null
}

output "ecr_registry_url" {
  description = "ECR registry URL (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].registry_url : null
}

output "ecr_docker_login_command" {
  description = "Docker login command for ECR (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].docker_login_command : null
}

output "ecr_docker_commands" {
  description = "Docker commands for each repository (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].docker_commands : null
}

output "ecr_repository_count" {
  description = "Number of ECR repositories (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].repository_count : null
}

output "ecr_summary" {
  description = "ECR configuration summary (if enabled)"
  value       = var.ecr_enabled ? module.ecr[0].summary : null
}

# -----------------------------------------------------------------------------
# ECS Outputs
# -----------------------------------------------------------------------------
output "ecs_cluster_id" {
  description = "ECS cluster ID (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].cluster_id : null
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].cluster_arn : null
}

output "ecs_cluster_name" {
  description = "ECS cluster name (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].cluster_name : null
}

output "ecs_capacity_providers" {
  description = "ECS cluster capacity providers (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].capacity_providers : null
}

output "ecs_task_definition_arns" {
  description = "Map of task definition ARNs (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].task_definition_arns : null
}

output "ecs_task_definition_families" {
  description = "Map of task definition families (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].task_definition_families : null
}

output "ecs_service_ids" {
  description = "Map of ECS service IDs (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].service_ids : null
}

output "ecs_service_names" {
  description = "Map of ECS service names (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].service_names : null
}

output "ecs_task_execution_role_arn" {
  description = "Task execution role ARN (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].task_execution_role_arn : null
}

output "ecs_task_role_arns" {
  description = "Map of task role ARNs (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].task_role_arns : null
}

output "ecs_log_group_names" {
  description = "Map of CloudWatch log group names (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].log_group_names : null
}

output "ecs_autoscaling_enabled" {
  description = "Map of services with autoscaling enabled (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].autoscaling_enabled : null
}

output "ecs_commands" {
  description = "Useful ECS CLI commands (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].commands : null
}

output "ecs_summary" {
  description = "ECS configuration summary (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].summary : null
}

output "ecs_service_info" {
  description = "Detailed service information (if enabled)"
  value       = var.ecs_enabled ? module.ecs[0].service_info : null
}
