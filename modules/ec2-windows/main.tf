# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_ami" "windows" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "platform"
    values = ["windows"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# -----------------------------------------------------------------------------
# Locals for Naming Convention
# -----------------------------------------------------------------------------
locals {
  # Service name defaults to 'ec2-windows' if not provided
  _service = coalesce(var.service, "ec2-windows")

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

  # Determine AMI ID
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.windows[0].id

  # Determine security group IDs
  security_group_ids = var.create_security_group ? concat([aws_security_group.this[0].id], var.security_group_ids) : var.security_group_ids

  # Determine IAM instance profile
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : (
    var.iam_instance_profile_arn != "" ? var.iam_instance_profile_arn : null
  )

  # IAM role name
  iam_role_name = var.iam_role_name != "" ? var.iam_role_name : "${local.name}-role"

  # Tags
  common_tags = merge(
    var.tags,
    {
      Name        = local.name
      Environment = var.environment
      Workload    = var.workload
      OS          = "Windows"
      ManagedBy   = "Terraform"
    }
  )
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${local.name}-sg"
  description = "Security group for ${local.name} Windows instance"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_ingress_rules :
    "${rule.protocol}-${rule.from_port}-${rule.to_port}-${idx}" => rule
  } : {}

  security_group_id = aws_security_group.this[0].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks[0]
  description       = each.value.description

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ingress-${each.key}"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = var.create_security_group ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = var.security_group_egress_cidr_blocks[0]
  description       = "Allow all outbound traffic"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-egress-all"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Role for Instance Profile
# -----------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = local.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = local.iam_role_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create_iam_instance_profile ? toset(var.iam_role_policies) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${local.name}-profile"
  role  = aws_iam_role.this[0].name

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-profile"
    }
  )
}

# -----------------------------------------------------------------------------
# EC2 Instance
# -----------------------------------------------------------------------------
resource "aws_instance" "this" {
  ami           = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  # Network
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = local.security_group_ids
  private_ip                  = var.private_ip != "" ? var.private_ip : null
  associate_public_ip_address = var.associate_public_ip_address
  source_dest_check           = var.source_dest_check

  # IAM
  iam_instance_profile = local.iam_instance_profile

  # Monitoring
  monitoring = var.monitoring

  # Protection
  disable_api_termination              = var.disable_api_termination
  disable_api_stop                     = var.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # User Data
  user_data                   = var.user_data != "" ? var.user_data : null
  user_data_replace_on_change = var.user_data_replace_on_change

  # Windows-specific
  get_password_data = var.get_password_data

  # Root Block Device
  root_block_device {
    volume_type           = var.root_block_device.volume_type
    volume_size           = var.root_block_device.volume_size
    iops                  = var.root_block_device.volume_type == "gp3" || var.root_block_device.volume_type == "io1" || var.root_block_device.volume_type == "io2" ? var.root_block_device.iops : null
    throughput            = var.root_block_device.volume_type == "gp3" ? var.root_block_device.throughput : null
    encrypted             = var.root_block_device.encrypted
    kms_key_id            = var.root_block_device.kms_key_id != "" ? var.root_block_device.kms_key_id : null
    delete_on_termination = var.root_block_device.delete_on_termination

    tags = merge(
      local.common_tags,
      {
        Name = "${local.name}-root"
      }
    )
  }

  # Additional EBS Volumes
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = ebs_block_device.value.volume_type
      volume_size           = ebs_block_device.value.volume_size
      iops                  = ebs_block_device.value.volume_type == "gp3" || ebs_block_device.value.volume_type == "io1" || ebs_block_device.value.volume_type == "io2" ? ebs_block_device.value.iops : null
      throughput            = ebs_block_device.value.volume_type == "gp3" ? ebs_block_device.value.throughput : null
      encrypted             = ebs_block_device.value.encrypted
      kms_key_id            = ebs_block_device.value.kms_key_id != "" ? ebs_block_device.value.kms_key_id : null
      delete_on_termination = ebs_block_device.value.delete_on_termination

      tags = merge(
        local.common_tags,
        {
          Name = "${local.name}-${ebs_block_device.value.device_name}"
        }
      )
    }
  }

  # Metadata Options (IMDSv2)
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  tags        = local.common_tags
  volume_tags = local.common_tags

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}
