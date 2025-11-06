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
  description = "Service name (e.g., linux, windows). If empty, will use 'keypair'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# Key Pair Configuration
# -----------------------------------------------------------------------------
variable "key_name" {
  type        = string
  default     = ""
  description = "Custom key pair name (if empty, will be auto-generated from naming convention)"
}

variable "algorithm" {
  type        = string
  default     = "RSA"
  description = "Algorithm to use for key generation (RSA, ECDSA, ED25519)"
  validation {
    condition     = contains(["RSA", "ECDSA", "ED25519"], var.algorithm)
    error_message = "Algorithm must be one of: RSA, ECDSA, ED25519."
  }
}

variable "rsa_bits" {
  type        = number
  default     = 4096
  description = "Number of bits for RSA key (2048 or 4096)"
  validation {
    condition     = contains([2048, 4096], var.rsa_bits)
    error_message = "RSA bits must be 2048 or 4096."
  }
}

variable "ecdsa_curve" {
  type        = string
  default     = "P384"
  description = "ECDSA curve to use (P224, P256, P384, P521)"
  validation {
    condition     = contains(["P224", "P256", "P384", "P521"], var.ecdsa_curve)
    error_message = "ECDSA curve must be one of: P224, P256, P384, P521."
  }
}

# -----------------------------------------------------------------------------
# Secrets Manager Configuration
# -----------------------------------------------------------------------------
variable "create_secret" {
  type        = bool
  default     = true
  description = "Store private key in AWS Secrets Manager"
}

variable "secret_name" {
  type        = string
  default     = ""
  description = "Custom secret name (if empty, will be auto-generated from key_name)"
}

variable "secret_description" {
  type        = string
  default     = ""
  description = "Description for the secret (if empty, will be auto-generated)"
}

variable "secret_recovery_window_in_days" {
  type        = number
  default     = 30
  description = "Number of days to retain secret after deletion (7-30)"
  validation {
    condition     = var.secret_recovery_window_in_days >= 7 && var.secret_recovery_window_in_days <= 30
    error_message = "Recovery window must be between 7 and 30 days."
  }
}

variable "secret_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for secret encryption (if empty, uses AWS managed key)"
}

variable "enable_secret_rotation" {
  type        = bool
  default     = false
  description = "Enable automatic secret rotation (requires Lambda function)"
}

variable "secret_rotation_lambda_arn" {
  type        = string
  default     = ""
  description = "Lambda function ARN for secret rotation"
}

variable "secret_rotation_days" {
  type        = number
  default     = 90
  description = "Number of days between automatic rotations"
}

# -----------------------------------------------------------------------------
# Output Configuration
# -----------------------------------------------------------------------------
variable "create_public_key_file" {
  type        = bool
  default     = false
  description = "Create a local file with the public key"
}

variable "public_key_file_path" {
  type        = string
  default     = ""
  description = "Path for public key file (if empty, will be auto-generated)"
}

variable "create_private_key_file" {
  type        = bool
  default     = false
  description = "Create a local file with the private key (NOT RECOMMENDED - use Secrets Manager)"
}

variable "private_key_file_path" {
  type        = string
  default     = ""
  description = "Path for private key file (if empty, will be auto-generated)"
}

variable "file_permission" {
  type        = string
  default     = "0400"
  description = "File permissions for key files (default: 0400 for read-only)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources"
}
