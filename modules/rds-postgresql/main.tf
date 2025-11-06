# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Locals for Naming Convention
# -----------------------------------------------------------------------------
locals {
  # Service name defaults to 'postgresql' if not provided
  _service = coalesce(var.service, "postgresql")

  # Build name from tokens
  _tokens = compact([
    var.org_prefix,
    var.environment,
    var.workload,
    local._service,
    var.identifier
  ])

  # Create normalized name
  _raw = join("-", local._tokens)
  name = trim(regexreplace(lower(local._raw), "[^a-z0-9-]", "-"), "-")

  # Database name
  database_name = var.database_name != "" ? var.database_name : "postgres"

  # Final snapshot identifier
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name}-${var.final_snapshot_identifier_prefix}-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  # Monitoring role name
  monitoring_role_name = "${local.name}-monitoring-role"

  # Security group IDs
  security_group_ids = var.create_security_group ? concat([aws_security_group.this[0].id], var.security_group_ids) : var.security_group_ids

  # Tags
  common_tags = merge(
    var.tags,
    {
      Name        = local.name
      Environment = var.environment
      Workload    = var.workload
      Engine      = "PostgreSQL"
      ManagedBy   = "Terraform"
    }
  )
}

# -----------------------------------------------------------------------------
# DB Subnet Group
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-subnet-group"
    }
  )
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${local.name}-sg"
  description = "Security group for ${local.name} PostgreSQL RDS"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? {
    for idx, cidr in var.allowed_cidr_blocks : idx => cidr
  } : {}

  security_group_id = aws_security_group.this[0].id
  from_port         = var.port
  to_port           = var.port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  description       = "PostgreSQL access from ${each.value}"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ingress-${each.key}"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  for_each = var.create_security_group && length(var.allowed_security_group_ids) > 0 ? {
    for idx, sg in var.allowed_security_group_ids : idx => sg
  } : {}

  security_group_id            = aws_security_group.this[0].id
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
  description                  = "PostgreSQL access from security group"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ingress-sg-${each.key}"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = var.create_security_group ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-egress-all"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Role for Enhanced Monitoring
# -----------------------------------------------------------------------------
resource "aws_iam_role" "monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  name = local.monitoring_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = local.monitoring_role_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# -----------------------------------------------------------------------------
# Parameter Group
# -----------------------------------------------------------------------------
resource "aws_db_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name   = "${local.name}-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-params"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# RDS Instance
# -----------------------------------------------------------------------------
resource "aws_db_instance" "this" {
  identifier = local.name

  # Engine
  engine         = "postgres"
  engine_version = var.engine_version

  # Instance
  instance_class        = var.instance_class
  availability_zone     = var.multi_az ? null : var.availability_zone
  multi_az              = var.multi_az
  publicly_accessible   = var.publicly_accessible
  ca_cert_identifier    = var.ca_cert_identifier

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id != "" ? var.kms_key_id : null
  iops                  = var.storage_type == "io1" || var.storage_type == "io2" || var.storage_type == "gp3" ? var.iops : null
  storage_throughput    = var.storage_type == "gp3" ? var.storage_throughput : null

  # Database
  db_name  = local.database_name
  username = var.master_username
  password = var.manage_master_user_password ? null : var.master_password
  port     = var.port

  # Password Management
  manage_master_user_password = var.manage_master_user_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = local.security_group_ids

  # Parameter Group
  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : null

  # Backup
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  delete_automated_backups  = var.delete_automated_backups

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately          = var.apply_immediately

  # Monitoring
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? (var.create_monitoring_role ? aws_iam_role.monitoring[0].arn : var.monitoring_role_arn) : null

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  # Advanced
  deletion_protection              = var.deletion_protection
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  tags        = local.common_tags
  
  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# -----------------------------------------------------------------------------
# Read Replicas
# -----------------------------------------------------------------------------
resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? var.read_replica_count : 0

  identifier = "${local.name}-replica-${count.index + 1}"

  # Replica Source
  replicate_source_db = aws_db_instance.this.identifier

  # Instance
  instance_class      = var.instance_class
  publicly_accessible = var.publicly_accessible

  # Storage
  storage_encrypted  = var.storage_encrypted
  kms_key_id         = var.kms_key_id != "" ? var.kms_key_id : null

  # Network
  vpc_security_group_ids = local.security_group_ids

  # Backup
  skip_final_snapshot       = var.skip_final_snapshot
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  # Maintenance
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Monitoring
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? (var.create_monitoring_role ? aws_iam_role.monitoring[0].arn : var.monitoring_role_arn) : null

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : null

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-replica-${count.index + 1}"
      Type = "ReadReplica"
    }
  )
}
