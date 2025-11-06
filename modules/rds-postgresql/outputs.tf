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
# Master User Password (Secrets Manager) - RDS Managed
# -----------------------------------------------------------------------------
output "master_user_secret_arn" {
  description = "The ARN of the master user secret (RDS-managed, password only)"
  value       = aws_db_instance.this.master_user_secret != null ? aws_db_instance.this.master_user_secret[0].secret_arn : null
}

output "master_user_secret_status" {
  description = "The status of the master user secret"
  value       = aws_db_instance.this.master_user_secret != null ? aws_db_instance.this.master_user_secret[0].secret_status : null
}

# -----------------------------------------------------------------------------
# Complete Connection Information (Secrets Manager) - Custom Secret
# -----------------------------------------------------------------------------
output "connection_secret_arn" {
  description = "The ARN of the complete connection secret (includes username, password, endpoint, port, database name)"
  value       = aws_secretsmanager_secret.db_connection.arn
}

output "connection_secret_name" {
  description = "The name of the complete connection secret"
  value       = aws_secretsmanager_secret.db_connection.name
}

output "connection_secret_id" {
  description = "The ID of the complete connection secret"
  value       = aws_secretsmanager_secret.db_connection.id
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
# Connection Information and Commands
# -----------------------------------------------------------------------------
output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${aws_db_instance.this.username}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
}

output "psql_command" {
  description = "psql command to connect to the database"
  value       = "psql -h ${aws_db_instance.this.address} -p ${aws_db_instance.this.port} -U ${aws_db_instance.this.username} -d ${aws_db_instance.this.db_name}"
}

output "retrieve_connection_info_command" {
  description = "AWS CLI command to retrieve complete connection information from Secrets Manager"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_connection.name} --query SecretString --output text | jq ."
}

output "retrieve_password_only_command" {
  description = "AWS CLI command to retrieve only the password from connection secret"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_connection.name} --query SecretString --output text | jq -r '.password'"
}

output "connection_info_example" {
  description = "Example of the connection information stored in Secrets Manager"
  value = jsonencode({
    username = "admin"
    password = "<password_value>"
    engine   = "postgres"
    host     = "<rds_endpoint>"
    port     = 5432
    dbname   = "<database_name>"
    endpoint = "<rds_endpoint>:5432"
  })
}
