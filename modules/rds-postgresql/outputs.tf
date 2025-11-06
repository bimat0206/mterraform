# -----------------------------------------------------------------------------
# RDS Instance Outputs
# -----------------------------------------------------------------------------
output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_identifier" {
  description = "The identifier of the RDS instance"
  value       = aws_db_instance.this.identifier
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_endpoint" {
  description = "The connection endpoint (hostname:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.this.status
}

output "db_instance_availability_zone" {
  description = "The availability zone of the instance"
  value       = aws_db_instance.this.availability_zone
}

output "db_instance_multi_az" {
  description = "If the RDS instance is multi AZ enabled"
  value       = aws_db_instance.this.multi_az
}

output "db_instance_engine" {
  description = "The database engine"
  value       = aws_db_instance.this.engine
}

output "db_instance_engine_version" {
  description = "The running version of the database"
  value       = aws_db_instance.this.engine_version_actual
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.this.resource_id
}

# -----------------------------------------------------------------------------
# Master User Password (Secrets Manager)
# -----------------------------------------------------------------------------
output "master_user_secret_arn" {
  description = "The ARN of the master user secret (Secrets Manager)"
  value       = aws_db_instance.this.master_user_secret != null ? aws_db_instance.this.master_user_secret[0].secret_arn : null
}

output "master_user_secret_status" {
  description = "The status of the master user secret"
  value       = aws_db_instance.this.master_user_secret != null ? aws_db_instance.this.master_user_secret[0].secret_status : null
}

# -----------------------------------------------------------------------------
# Security Group Outputs
# -----------------------------------------------------------------------------
output "security_group_id" {
  description = "The ID of the security group"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

output "security_group_name" {
  description = "The name of the security group"
  value       = var.create_security_group ? aws_security_group.this[0].name : null
}

# -----------------------------------------------------------------------------
# Subnet Group Outputs
# -----------------------------------------------------------------------------
output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.this.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = aws_db_subnet_group.this.arn
}

# -----------------------------------------------------------------------------
# Parameter Group Outputs
# -----------------------------------------------------------------------------
output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].id : null
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = var.create_parameter_group ? aws_db_parameter_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Monitoring Outputs
# -----------------------------------------------------------------------------
output "monitoring_role_arn" {
  description = "The ARN of the enhanced monitoring IAM role"
  value       = var.create_monitoring_role && var.monitoring_interval > 0 ? aws_iam_role.monitoring[0].arn : null
}

output "performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  value       = aws_db_instance.this.performance_insights_enabled
}

# -----------------------------------------------------------------------------
# Read Replica Outputs
# -----------------------------------------------------------------------------
output "read_replica_ids" {
  description = "List of read replica instance IDs"
  value       = aws_db_instance.replica[*].id
}

output "read_replica_arns" {
  description = "List of read replica ARNs"
  value       = aws_db_instance.replica[*].arn
}

output "read_replica_endpoints" {
  description = "List of read replica endpoints"
  value       = aws_db_instance.replica[*].endpoint
}

output "read_replica_addresses" {
  description = "List of read replica addresses"
  value       = aws_db_instance.replica[*].address
}

# -----------------------------------------------------------------------------
# Connection Information
# -----------------------------------------------------------------------------
output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.this.username}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
}

output "psql_command" {
  description = "psql command to connect to the database"
  value       = "psql -h ${aws_db_instance.this.address} -p ${aws_db_instance.this.port} -U ${aws_db_instance.this.username} -d ${aws_db_instance.this.db_name}"
}

output "retrieve_password_command" {
  description = "AWS CLI command to retrieve master password from Secrets Manager"
  value       = aws_db_instance.this.master_user_secret != null ? "aws secretsmanager get-secret-value --secret-id ${aws_db_instance.this.master_user_secret[0].secret_arn} --query SecretString --output text | jq -r '.password'" : "N/A - password managed manually"
}
