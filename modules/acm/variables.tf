# -----------------------------------------------------------------------------
# Naming convention inputs
# -----------------------------------------------------------------------------
variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming (e.g., 'tsk')"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'prod', 'staging')"
}

variable "workload" {
  type        = string
  description = "Workload name (e.g., 'app', 'platform')"
}

variable "service" {
  type        = string
  default     = null
  description = "Service name override. Defaults to 'acm' if not provided"
}

variable "identifier" {
  type        = string
  default     = null
  description = "Unique identifier for the resource (e.g., '01', 'a')"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# ACM certificate configuration inputs
# -----------------------------------------------------------------------------
variable "domain_name" {
  type        = string
  description = "Primary domain name for the certificate (e.g., 'example.com')"
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "Subject Alternative Names (SANs) for the certificate (e.g., ['*.example.com', 'www.example.com'])"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for DNS validation"
}

variable "validation_ttl" {
  type        = number
  default     = 60
  description = "TTL for DNS validation records"
}
