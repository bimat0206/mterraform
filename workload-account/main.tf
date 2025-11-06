# -----------------------------------------------------------------------------
# Key Pair Module for Linux (optional)
# -----------------------------------------------------------------------------
module "keypair_linux" {
  count  = var.create_keypair_linux ? 1 : 0
  source = "../modules/keypair"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "linux"
  identifier  = "01"

  # Key Pair Configuration
  algorithm = var.keypair_algorithm
  rsa_bits  = var.keypair_rsa_bits

  # Secrets Manager Configuration
  create_secret                 = var.keypair_store_in_secretsmanager
  secret_recovery_window_in_days = var.keypair_secret_recovery_window
  secret_kms_key_id             = var.keypair_kms_key_id

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Key Pair Module for Windows (optional)
# -----------------------------------------------------------------------------
module "keypair_windows" {
  count  = var.create_keypair_windows ? 1 : 0
  source = "../modules/keypair"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "windows"
  identifier  = "01"

  # Key Pair Configuration
  algorithm = var.keypair_algorithm
  rsa_bits  = var.keypair_rsa_bits

  # Secrets Manager Configuration
  create_secret                 = var.keypair_store_in_secretsmanager
  secret_recovery_window_in_days = var.keypair_secret_recovery_window
  secret_kms_key_id             = var.keypair_kms_key_id

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Locals for Key Pair Names
# -----------------------------------------------------------------------------
locals {
  linux_key_name = var.create_keypair_linux ? module.keypair_linux[0].key_pair_name : (
    var.ec2_linux_existing_key_name != "" ? var.ec2_linux_existing_key_name : var.ec2_linux_key_name
  )

  windows_key_name = var.create_keypair_windows ? module.keypair_windows[0].key_pair_name : (
    var.ec2_windows_existing_key_name != "" ? var.ec2_windows_existing_key_name : var.ec2_windows_key_name
  )
}

# -----------------------------------------------------------------------------
# EC2 Linux Module (optional)
# -----------------------------------------------------------------------------
module "ec2_linux" {
  count  = var.ec2_linux_enabled ? 1 : 0
  source = "../modules/ec2-linux"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "app"
  identifier  = "01"

  # Network Configuration
  vpc_id                      = var.vpc_id
  subnet_id                   = var.ec2_linux_associate_public_ip ? var.public_subnet_ids[0] : var.private_subnet_ids[0]
  associate_public_ip_address = var.ec2_linux_associate_public_ip

  # Instance Configuration
  instance_type = var.ec2_linux_instance_type
  ami_id        = var.ec2_linux_ami_id
  key_name      = local.linux_key_name  # Use keypair module or existing/manual key
  monitoring    = var.ec2_linux_monitoring
  user_data     = var.ec2_linux_user_data

  # Storage Configuration
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = var.ec2_linux_root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  # IAM Configuration
  create_iam_instance_profile = var.ec2_linux_create_iam_profile
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  # Security Group Configuration
  create_security_group        = true
  security_group_ingress_rules = var.ec2_linux_security_group_ingress_rules

  # Tags
  tags = local.common_tags

  # Ensure key pair is created before EC2 instance
  depends_on = [module.keypair_linux]
}

# -----------------------------------------------------------------------------
# EC2 Windows Module (optional)
# -----------------------------------------------------------------------------
module "ec2_windows" {
  count  = var.ec2_windows_enabled ? 1 : 0
  source = "../modules/ec2-windows"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "app"
  identifier  = "01"

  # Network Configuration
  vpc_id                      = var.vpc_id
  subnet_id                   = var.ec2_windows_associate_public_ip ? var.public_subnet_ids[0] : var.private_subnet_ids[0]
  associate_public_ip_address = var.ec2_windows_associate_public_ip

  # Instance Configuration
  instance_type     = var.ec2_windows_instance_type
  ami_id            = var.ec2_windows_ami_id
  key_name          = local.windows_key_name  # Use keypair module or existing/manual key
  monitoring        = var.ec2_windows_monitoring
  user_data         = var.ec2_windows_user_data
  get_password_data = var.ec2_windows_get_password_data

  # Storage Configuration
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = var.ec2_windows_root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  # IAM Configuration
  create_iam_instance_profile = var.ec2_windows_create_iam_profile
  iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  # Security Group Configuration
  create_security_group        = true
  security_group_ingress_rules = var.ec2_windows_security_group_ingress_rules

  # Tags
  tags = local.common_tags

  # Ensure key pair is created before EC2 instance
  depends_on = [module.keypair_windows]
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL Module (optional)
# -----------------------------------------------------------------------------
module "rds_postgresql" {
  count  = var.rds_postgresql_enabled ? 1 : 0
  source = "../modules/rds-postgresql"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "db"
  identifier  = "01"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Database Configuration
  instance_class    = var.rds_postgresql_instance_class
  engine_version    = var.rds_postgresql_engine_version
  allocated_storage = var.rds_postgresql_allocated_storage
  database_name     = var.rds_postgresql_database_name
  master_username   = var.rds_postgresql_master_username

  # High Availability
  multi_az = var.rds_postgresql_multi_az

  # Backup
  backup_retention_period = var.rds_postgresql_backup_retention_period

  # Security
  create_security_group   = true
  allowed_cidr_blocks     = var.rds_postgresql_allowed_cidr_blocks
  deletion_protection     = var.rds_postgresql_deletion_protection

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  # Storage
  storage_encrypted = true

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# RDS MySQL Module (optional)
# -----------------------------------------------------------------------------
module "rds_mysql" {
  count  = var.rds_mysql_enabled ? 1 : 0
  source = "../modules/rds-mysql"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "db"
  identifier  = "01"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Database Configuration
  instance_class    = var.rds_mysql_instance_class
  engine_version    = var.rds_mysql_engine_version
  allocated_storage = var.rds_mysql_allocated_storage
  database_name     = var.rds_mysql_database_name
  master_username   = var.rds_mysql_master_username

  # High Availability
  multi_az = var.rds_mysql_multi_az

  # Backup
  backup_retention_period = var.rds_mysql_backup_retention_period

  # Security
  create_security_group   = true
  allowed_cidr_blocks     = var.rds_mysql_allowed_cidr_blocks
  deletion_protection     = var.rds_mysql_deletion_protection

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  # Storage
  storage_encrypted = true

  # Tags
  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# RDS SQL Server Module (optional)
# -----------------------------------------------------------------------------
module "rds_sqlserver" {
  count  = var.rds_sqlserver_enabled ? 1 : 0
  source = "../modules/rds-sqlserver"

  # Naming inputs
  org_prefix  = local.naming.org_prefix
  environment = local.naming.environment
  workload    = local.naming.workload
  service     = "db"
  identifier  = "02"

  # Network Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Database Configuration
  engine            = var.rds_sqlserver_engine
  engine_version    = var.rds_sqlserver_engine_version
  instance_class    = var.rds_sqlserver_instance_class
  allocated_storage = var.rds_sqlserver_allocated_storage
  database_name     = var.rds_sqlserver_database_name
  master_username   = var.rds_sqlserver_master_username

  # High Availability
  multi_az = var.rds_sqlserver_multi_az

  # Backup
  backup_retention_period = var.rds_sqlserver_backup_retention_period

  # Security
  create_security_group   = true
  allowed_cidr_blocks     = var.rds_sqlserver_allowed_cidr_blocks
  deletion_protection     = var.rds_sqlserver_deletion_protection

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  # Storage
  storage_encrypted = true

  # Tags
  tags = local.common_tags
}
