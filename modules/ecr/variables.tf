# Naming inputs
variable "org_prefix" {
  type        = string
  description = "Organization prefix for naming resources"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "workload" {
  type        = string
  description = "Workload or application name"
}

# ECR Repository Configuration
variable "repositories" {
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")
    kms_key_arn          = optional(string, null)

    # Lifecycle policy
    lifecycle_policy = optional(object({
      max_image_count        = optional(number, 30)
      max_untagged_days      = optional(number, 7)
      max_tagged_days        = optional(number, 90)
      protected_tags         = optional(list(string), ["latest", "prod", "production"])
      enable_untagged_expiry = optional(bool, true)
    }), {})

    # Repository policy
    repository_policy = optional(string, null)

    # Force delete
    force_delete = optional(bool, false)

    # Tags
    tags = optional(map(string), {})
  }))
  description = "Map of ECR repository configurations"
  default     = {}
}

# Image Scanning Configuration
variable "enable_enhanced_scanning" {
  type        = bool
  default     = false
  description = "Enable AWS Inspector enhanced scanning (additional cost)"
}

variable "scan_frequency" {
  type        = string
  default     = "SCAN_ON_PUSH"
  description = "Scan frequency for enhanced scanning: SCAN_ON_PUSH, CONTINUOUS_SCAN, or MANUAL"
  validation {
    condition     = contains(["SCAN_ON_PUSH", "CONTINUOUS_SCAN", "MANUAL"], var.scan_frequency)
    error_message = "Scan frequency must be SCAN_ON_PUSH, CONTINUOUS_SCAN, or MANUAL"
  }
}

# Replication Configuration
variable "enable_replication" {
  type        = bool
  default     = false
  description = "Enable cross-region or cross-account replication"
}

variable "replication_configuration" {
  type = object({
    rules = list(object({
      destinations = list(object({
        region      = string
        registry_id = optional(string)
      }))
      repository_filters = optional(list(object({
        filter      = string
        filter_type = string
      })), [])
    }))
  })
  default = {
    rules = []
  }
  description = "Replication configuration for ECR repositories"
}

# Pull Through Cache Configuration
variable "enable_pull_through_cache" {
  type        = bool
  default     = false
  description = "Enable pull through cache for public registries"
}

variable "pull_through_cache_rules" {
  type = map(object({
    upstream_registry_url = string
    credential_arn        = optional(string)
  }))
  default     = {}
  description = "Pull through cache rules for public registries (e.g., Docker Hub, GitHub Container Registry)"
}

# Common tags
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to apply to all resources"
}
