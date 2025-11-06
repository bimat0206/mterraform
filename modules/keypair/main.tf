# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Locals for Naming Convention
# -----------------------------------------------------------------------------
locals {
  # Service name defaults to 'keypair' if not provided
  _service = coalesce(var.service, "keypair")

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

  # Key pair name
  key_name = var.key_name != "" ? var.key_name : local.name

  # Secret name and description
  secret_name        = var.secret_name != "" ? var.secret_name : "${local.key_name}-private-key"
  secret_description = var.secret_description != "" ? var.secret_description : "Private key for EC2 key pair: ${local.key_name}"

  # File paths
  public_key_file_path  = var.public_key_file_path != "" ? var.public_key_file_path : "${path.root}/${local.key_name}.pub"
  private_key_file_path = var.private_key_file_path != "" ? var.private_key_file_path : "${path.root}/${local.key_name}.pem"

  # Tags
  common_tags = merge(
    var.tags,
    {
      Name        = local.key_name
      Environment = var.environment
      Workload    = var.workload
      ManagedBy   = "Terraform"
    }
  )
}

# -----------------------------------------------------------------------------
# Generate Private Key
# -----------------------------------------------------------------------------
resource "tls_private_key" "this" {
  algorithm   = var.algorithm
  rsa_bits    = var.algorithm == "RSA" ? var.rsa_bits : null
  ecdsa_curve = var.algorithm == "ECDSA" ? var.ecdsa_curve : null
}

# -----------------------------------------------------------------------------
# Create EC2 Key Pair
# -----------------------------------------------------------------------------
resource "aws_key_pair" "this" {
  key_name   = local.key_name
  public_key = tls_private_key.this.public_key_openssh

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Store Private Key in Secrets Manager
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "private_key" {
  count = var.create_secret ? 1 : 0

  name                    = local.secret_name
  description             = local.secret_description
  recovery_window_in_days = var.secret_recovery_window_in_days
  kms_key_id              = var.secret_kms_key_id != "" ? var.secret_kms_key_id : null

  tags = merge(
    local.common_tags,
    {
      Name     = local.secret_name
      KeyPair  = local.key_name
      KeyType  = "EC2-PrivateKey"
      Format   = "PEM"
    }
  )
}

resource "aws_secretsmanager_secret_version" "private_key" {
  count = var.create_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.private_key[0].id
  secret_string = jsonencode({
    key_name    = local.key_name
    key_pair_id = aws_key_pair.this.id
    algorithm   = var.algorithm
    private_key = tls_private_key.this.private_key_pem
    public_key  = tls_private_key.this.public_key_openssh
    fingerprint = aws_key_pair.this.fingerprint
    created_at  = timestamp()
  })
}

# -----------------------------------------------------------------------------
# Secret Rotation Configuration (Optional)
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret_rotation" "private_key" {
  count = var.create_secret && var.enable_secret_rotation && var.secret_rotation_lambda_arn != "" ? 1 : 0

  secret_id           = aws_secretsmanager_secret.private_key[0].id
  rotation_lambda_arn = var.secret_rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }
}

# -----------------------------------------------------------------------------
# Local Files (Optional - NOT RECOMMENDED for production)
# -----------------------------------------------------------------------------
resource "local_file" "public_key" {
  count = var.create_public_key_file ? 1 : 0

  content         = tls_private_key.this.public_key_openssh
  filename        = local.public_key_file_path
  file_permission = var.file_permission
}

resource "local_file" "private_key" {
  count = var.create_private_key_file ? 1 : 0

  content         = tls_private_key.this.private_key_pem
  filename        = local.private_key_file_path
  file_permission = var.file_permission

  lifecycle {
    precondition {
      condition     = var.create_private_key_file == false || var.create_secret == true
      error_message = "WARNING: Creating private key files is not recommended. Use Secrets Manager (create_secret = true) instead."
    }
  }
}
