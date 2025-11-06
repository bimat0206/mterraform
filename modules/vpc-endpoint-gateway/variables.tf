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
  description = "Service name override. Defaults to 'vpce-gw' if not provided"
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
# VPC Configuration
# -----------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC ID where endpoints will be created"
}

# -----------------------------------------------------------------------------
# Gateway Endpoint Configuration
# -----------------------------------------------------------------------------
variable "enable_s3_endpoint" {
  type        = bool
  default     = true
  description = "Enable S3 VPC Gateway Endpoint (no charge)"
}

variable "enable_dynamodb_endpoint" {
  type        = bool
  default     = false
  description = "Enable DynamoDB VPC Gateway Endpoint (no charge)"
}

# -----------------------------------------------------------------------------
# Route Table Configuration
# -----------------------------------------------------------------------------
variable "route_table_ids" {
  type        = list(string)
  description = "List of route table IDs to associate with gateway endpoints"
}

variable "s3_endpoint_policy" {
  type        = string
  default     = null
  description = "IAM policy document for S3 endpoint (JSON). If null, allows all access"
}

variable "dynamodb_endpoint_policy" {
  type        = string
  default     = null
  description = "IAM policy document for DynamoDB endpoint (JSON). If null, allows all access"
}
