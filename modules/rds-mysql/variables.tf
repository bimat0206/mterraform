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
  description = "Service name (e.g., api, web). If empty, will use 'mysql'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for DB subnet group (minimum 2 in different AZs)"
}

variable "availability_zone" {
  type        = string
  default     = ""
  description = "AZ for single-AZ deployment (leave empty for multi-AZ)"
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------
variable "engine_version" {
  type        = string
  default     = "8.0.35"
  description = "MySQL engine version (8.0.x, 5.7.x, etc.)"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class (db.t3.micro, db.t3.small, db.r6g.large, etc.)"
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB"
}

variable "max_allocated_storage" {
  type        = number
  default     = 100
  description = "Maximum storage for autoscaling (0 = disabled)"
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type (gp2, gp3, io1, io2)"
}

variable "iops" {
  type        = number
  default     = 3000
  description = "IOPS for io1/io2 or gp3 storage"
}

variable "storage_throughput" {
  type        = number
  default     = 125
  description = "Storage throughput in MB/s for gp3"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Enable storage encryption"
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for storage encryption (empty = AWS managed key)"
}

# -----------------------------------------------------------------------------
# Database Credentials
# -----------------------------------------------------------------------------
variable "database_name" {
  type        = string
  default     = ""
  description = "Initial database name"
}

variable "master_username" {
  type        = string
  default     = "admin"
  description = "Master username for the database"
}

variable "manage_master_user_password" {
  type        = bool
  default     = true
  description = "Manage master password in Secrets Manager (RDS managed)"
}

variable "master_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Master password (only if manage_master_user_password = false)"
}

variable "port" {
  type        = number
  default     = 3306
  description = "Database port"
}

# -----------------------------------------------------------------------------
# High Availability Configuration
# -----------------------------------------------------------------------------
variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment"
}

variable "create_read_replica" {
  type        = bool
  default     = false
  description = "Create read replica"
}

variable "read_replica_count" {
  type        = number
  default     = 1
  description = "Number of read replicas to create"
}

# -----------------------------------------------------------------------------
# Backup Configuration
# -----------------------------------------------------------------------------
variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Backup retention period in days (0-35)"
}

variable "backup_window" {
  type        = string
  default     = "03:00-04:00"
  description = "Preferred backup window (UTC)"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Skip final snapshot on deletion"
}

variable "final_snapshot_identifier_prefix" {
  type        = string
  default     = "final"
  description = "Prefix for final snapshot identifier"
}

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Copy tags to snapshots"
}

variable "delete_automated_backups" {
  type        = bool
  default     = true
  description = "Delete automated backups on instance deletion"
}

# -----------------------------------------------------------------------------
# Maintenance Configuration
# -----------------------------------------------------------------------------
variable "maintenance_window" {
  type        = string
  default     = "sun:04:00-sun:05:00"
  description = "Preferred maintenance window (UTC)"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Enable automatic minor version upgrades"
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Allow major version upgrades"
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Apply changes immediately (true) or during maintenance window (false)"
}

# -----------------------------------------------------------------------------
# Monitoring Configuration
# -----------------------------------------------------------------------------
variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["error", "general", "slowquery"]
  description = "CloudWatch Logs exports (error, general, slowquery, audit)"
}

variable "monitoring_interval" {
  type        = number
  default     = 60
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
}

variable "create_monitoring_role" {
  type        = bool
  default     = true
  description = "Create IAM role for enhanced monitoring"
}

variable "monitoring_role_arn" {
  type        = string
  default     = ""
  description = "Existing monitoring role ARN (if create_monitoring_role = false)"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable Performance Insights"
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Performance Insights retention in days (7 or 731)"
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key for Performance Insights encryption"
}

# -----------------------------------------------------------------------------
# Security Group Configuration
# -----------------------------------------------------------------------------
variable "create_security_group" {
  type        = bool
  default     = true
  description = "Create security group for RDS"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional security group IDs"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to access RDS"
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs allowed to access RDS"
}

# -----------------------------------------------------------------------------
# Parameter Group Configuration
# -----------------------------------------------------------------------------
variable "create_parameter_group" {
  type        = bool
  default     = true
  description = "Create custom parameter group"
}

variable "parameter_group_family" {
  type        = string
  default     = "mysql8.0"
  description = "Parameter group family (mysql5.7, mysql8.0, etc.)"
}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default     = []
  description = "Custom database parameters"
}

# -----------------------------------------------------------------------------
# Option Group Configuration
# -----------------------------------------------------------------------------
variable "create_option_group" {
  type        = bool
  default     = false
  description = "Create custom option group"
}

variable "major_engine_version" {
  type        = string
  default     = "8.0"
  description = "Major engine version for option group"
}

variable "options" {
  type = list(object({
    option_name = string
    option_settings = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
  default     = []
  description = "Option group options"
}

# -----------------------------------------------------------------------------
# Advanced Configuration
# -----------------------------------------------------------------------------
variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Make RDS publicly accessible"
}

variable "ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
  description = "CA certificate identifier"
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable IAM database authentication"
}

variable "character_set_name" {
  type        = string
  default     = "utf8mb4"
  description = "Character set for database"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources"
}
