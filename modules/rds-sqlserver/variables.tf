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
  description = "Service name (e.g., api, web). If empty, will use 'sqlserver'"
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
  description = "Additional security group IDs to attach"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to connect to RDS"
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs allowed to connect to RDS"
}

# -----------------------------------------------------------------------------
# Engine Configuration
# -----------------------------------------------------------------------------
variable "engine" {
  type        = string
  default     = "sqlserver-se"
  description = "SQL Server engine type (sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web)"

  validation {
    condition     = contains(["sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], var.engine)
    error_message = "Engine must be one of: sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web"
  }
}

variable "engine_version" {
  type        = string
  default     = "15.00.4335.1.v1"
  description = "SQL Server engine version (e.g., 15.00 for SQL Server 2019, 16.00 for SQL Server 2022)"
}

variable "major_engine_version" {
  type        = string
  default     = "15.00"
  description = "Major engine version for option group (e.g., 15.00, 16.00)"
}

# -----------------------------------------------------------------------------
# Instance Configuration
# -----------------------------------------------------------------------------
variable "instance_class" {
  type        = string
  default     = "db.t3.xlarge"
  description = "RDS instance class (SQL Server requires minimum db.t3.xlarge for Standard Edition)"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment for high availability"
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------
variable "allocated_storage" {
  type        = number
  default     = 100
  description = "Initial allocated storage in GB (minimum 20 for SQL Server)"
}

variable "max_allocated_storage" {
  type        = number
  default     = 1000
  description = "Maximum storage for autoscaling in GB (0 to disable)"
}

variable "storage_type" {
  type        = string
  default     = "gp3"
  description = "Storage type (gp2, gp3, io1, io2)"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Enable storage encryption"
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for storage encryption (leave empty for default)"
}

variable "iops" {
  type        = number
  default     = null
  description = "Provisioned IOPS (required for io1/io2, optional for gp3)"
}

variable "storage_throughput" {
  type        = number
  default     = null
  description = "Storage throughput in MB/s (gp3 only, 125-1000)"
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------
variable "database_name" {
  type        = string
  default     = ""
  description = "Initial database name (optional, SQL Server will use default databases)"
}

variable "master_username" {
  type        = string
  default     = "sqladmin"
  description = "Master username (cannot be 'admin', 'administrator', 'sa', 'root')"

  validation {
    condition     = !contains(["admin", "administrator", "sa", "root"], lower(var.master_username))
    error_message = "Master username cannot be 'admin', 'administrator', 'sa', or 'root'"
  }
}

variable "master_password" {
  type        = string
  default     = ""
  description = "Master password (only used if manage_master_user_password is false)"
  sensitive   = true
}

variable "port" {
  type        = number
  default     = 1433
  description = "Database port"
}

# -----------------------------------------------------------------------------
# Password Management
# -----------------------------------------------------------------------------
variable "manage_master_user_password" {
  type        = bool
  default     = true
  description = "Let RDS manage master password in Secrets Manager"
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
  description = "Apply changes immediately (may cause downtime)"
}

# -----------------------------------------------------------------------------
# Monitoring Configuration
# -----------------------------------------------------------------------------
variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["agent", "error"]
  description = "List of log types to export to CloudWatch (agent, error)"
}

variable "monitoring_interval" {
  type        = number
  default     = 60
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds"
  }
}

variable "monitoring_role_arn" {
  type        = string
  default     = ""
  description = "IAM role ARN for enhanced monitoring (leave empty to create)"
}

variable "create_monitoring_role" {
  type        = bool
  default     = true
  description = "Create IAM role for enhanced monitoring"
}

# -----------------------------------------------------------------------------
# Performance Insights Configuration
# -----------------------------------------------------------------------------
variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable Performance Insights"
}

variable "performance_insights_retention_period" {
  type        = number
  default     = 7
  description = "Performance Insights retention period in days (7 or 731)"

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention must be 7 or 731 days"
  }
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for Performance Insights encryption"
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
  default     = "sqlserver-se-15.0"
  description = "Parameter group family (e.g., sqlserver-se-15.0, sqlserver-ee-16.0)"
}

variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default     = []
  description = "Custom database parameters"
}

# -----------------------------------------------------------------------------
# Option Group Configuration
# -----------------------------------------------------------------------------
variable "create_option_group" {
  type        = bool
  default     = true
  description = "Create custom option group"
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
  description = "Option group options (e.g., SQLSERVER_AUDIT, TDE)"
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

variable "timezone" {
  type        = string
  default     = "UTC"
  description = "SQL Server timezone"
}

variable "character_set_name" {
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  description = "SQL Server collation"
}

variable "license_model" {
  type        = string
  default     = "license-included"
  description = "License model (license-included or bring-your-own-license)"

  validation {
    condition     = contains(["license-included", "bring-your-own-license"], var.license_model)
    error_message = "License model must be 'license-included' or 'bring-your-own-license'"
  }
}

# -----------------------------------------------------------------------------
# Read Replica Configuration
# -----------------------------------------------------------------------------
variable "create_read_replica" {
  type        = bool
  default     = false
  description = "Create read replicas"
}

variable "read_replica_count" {
  type        = number
  default     = 1
  description = "Number of read replicas to create"
}

# -----------------------------------------------------------------------------
# Secrets Manager Configuration
# -----------------------------------------------------------------------------
variable "secret_recovery_window_in_days" {
  type        = number
  default     = 30
  description = "Number of days to retain deleted secrets (0 for immediate deletion, 7-30 for recovery window)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources"
}
