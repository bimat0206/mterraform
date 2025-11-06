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
  key_name      = var.ec2_linux_key_name
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
  key_name          = var.ec2_windows_key_name
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
}
