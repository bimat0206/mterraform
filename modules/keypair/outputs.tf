# -----------------------------------------------------------------------------
# Key Pair Outputs
# -----------------------------------------------------------------------------
output "key_pair_name" {
  description = "The name of the EC2 key pair"
  value       = aws_key_pair.this.key_name
}

output "key_pair_id" {
  description = "The ID of the EC2 key pair"
  value       = aws_key_pair.this.id
}

output "key_pair_arn" {
  description = "The ARN of the EC2 key pair"
  value       = aws_key_pair.this.arn
}

output "key_pair_fingerprint" {
  description = "The MD5 fingerprint of the key pair"
  value       = aws_key_pair.this.fingerprint
}

# -----------------------------------------------------------------------------
# Public Key Outputs
# -----------------------------------------------------------------------------
output "public_key_openssh" {
  description = "The public key in OpenSSH format"
  value       = tls_private_key.this.public_key_openssh
}

output "public_key_pem" {
  description = "The public key in PEM format"
  value       = tls_private_key.this.public_key_pem
}

output "public_key_fingerprint_md5" {
  description = "MD5 fingerprint of the public key"
  value       = tls_private_key.this.public_key_fingerprint_md5
}

output "public_key_fingerprint_sha256" {
  description = "SHA256 fingerprint of the public key"
  value       = tls_private_key.this.public_key_fingerprint_sha256
}

# -----------------------------------------------------------------------------
# Private Key Outputs (Sensitive)
# -----------------------------------------------------------------------------
output "private_key_pem" {
  description = "The private key in PEM format (sensitive)"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}

output "private_key_openssh" {
  description = "The private key in OpenSSH format (sensitive)"
  value       = tls_private_key.this.private_key_openssh
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Secrets Manager Outputs
# -----------------------------------------------------------------------------
output "secret_id" {
  description = "The ID of the secret in Secrets Manager (if created)"
  value       = var.create_secret ? aws_secretsmanager_secret.private_key[0].id : null
}

output "secret_arn" {
  description = "The ARN of the secret in Secrets Manager (if created)"
  value       = var.create_secret ? aws_secretsmanager_secret.private_key[0].arn : null
}

output "secret_name" {
  description = "The name of the secret in Secrets Manager (if created)"
  value       = var.create_secret ? aws_secretsmanager_secret.private_key[0].name : null
}

output "secret_version_id" {
  description = "The version ID of the secret (if created)"
  value       = var.create_secret ? aws_secretsmanager_secret_version.private_key[0].version_id : null
}

# -----------------------------------------------------------------------------
# File Outputs
# -----------------------------------------------------------------------------
output "public_key_file_path" {
  description = "Path to the public key file (if created)"
  value       = var.create_public_key_file ? local_file.public_key[0].filename : null
}

output "private_key_file_path" {
  description = "Path to the private key file (if created)"
  value       = var.create_private_key_file ? local_file.private_key[0].filename : null
}

# -----------------------------------------------------------------------------
# Usage Instructions
# -----------------------------------------------------------------------------
output "ssh_usage_command" {
  description = "Example SSH command using this key pair"
  value       = "ssh -i /path/to/${local.key_name}.pem ec2-user@<instance-ip>"
}

output "retrieve_secret_command" {
  description = "AWS CLI command to retrieve private key from Secrets Manager"
  value       = var.create_secret ? "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.private_key[0].name} --query SecretString --output text | jq -r '.private_key' > ${local.key_name}.pem && chmod 400 ${local.key_name}.pem" : "N/A - secret not created"
}

output "decrypt_windows_password_command" {
  description = "Command to decrypt Windows password using the private key"
  value       = var.create_secret ? "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.private_key[0].name} --query SecretString --output text | jq -r '.private_key' > /tmp/${local.key_name}.pem && aws ec2 get-password-data --instance-id <instance-id> --priv-launch-key /tmp/${local.key_name}.pem && rm /tmp/${local.key_name}.pem" : "N/A - secret not created"
}

# -----------------------------------------------------------------------------
# Algorithm Information
# -----------------------------------------------------------------------------
output "algorithm" {
  description = "The algorithm used for key generation"
  value       = var.algorithm
}

output "key_size" {
  description = "The key size (for RSA) or curve (for ECDSA)"
  value       = var.algorithm == "RSA" ? "${var.rsa_bits} bits" : (var.algorithm == "ECDSA" ? var.ecdsa_curve : "ED25519")
}
