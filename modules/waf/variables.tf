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
  description = "Service name (e.g., api, web). If empty, will use 'waf'"
}

variable "identifier" {
  type        = string
  default     = ""
  description = "Resource identifier (e.g., 01, 02)"
}

# -----------------------------------------------------------------------------
# WAF Configuration
# -----------------------------------------------------------------------------
variable "scope" {
  type        = string
  default     = "REGIONAL"
  description = "Scope of the WAF: REGIONAL (for ALB, API Gateway) or CLOUDFRONT"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be either REGIONAL or CLOUDFRONT"
  }
}

variable "default_action" {
  type        = string
  default     = "allow"
  description = "Default action for requests that don't match any rule (allow or block)"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either 'allow' or 'block'"
  }
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the Web ACL"
}

# -----------------------------------------------------------------------------
# AWS Managed Rule Groups
# -----------------------------------------------------------------------------
variable "enable_aws_managed_rules" {
  type        = bool
  default     = true
  description = "Enable AWS Managed Rules"
}

variable "enable_core_rule_set" {
  type        = bool
  default     = true
  description = "Enable AWS Managed Core Rule Set (protects against common threats)"
}

variable "core_rule_set_priority" {
  type        = number
  default     = 10
  description = "Priority for Core Rule Set (lower number = higher priority)"
}

variable "enable_known_bad_inputs" {
  type        = bool
  default     = true
  description = "Enable Known Bad Inputs rule set (protects against known malicious inputs)"
}

variable "known_bad_inputs_priority" {
  type        = number
  default     = 20
  description = "Priority for Known Bad Inputs rule set"
}

variable "enable_sql_injection" {
  type        = bool
  default     = true
  description = "Enable SQL Injection rule set"
}

variable "sql_injection_priority" {
  type        = number
  default     = 30
  description = "Priority for SQL Injection rule set"
}

variable "enable_linux_os" {
  type        = bool
  default     = false
  description = "Enable Linux OS rule set (protects against LFI attacks)"
}

variable "linux_os_priority" {
  type        = number
  default     = 40
  description = "Priority for Linux OS rule set"
}

variable "enable_unix_os" {
  type        = bool
  default     = false
  description = "Enable Unix OS rule set"
}

variable "unix_os_priority" {
  type        = number
  default     = 50
  description = "Priority for Unix OS rule set"
}

variable "enable_windows_os" {
  type        = bool
  default     = false
  description = "Enable Windows OS rule set"
}

variable "windows_os_priority" {
  type        = number
  default     = 60
  description = "Priority for Windows OS rule set"
}

variable "enable_php_app" {
  type        = bool
  default     = false
  description = "Enable PHP Application rule set"
}

variable "php_app_priority" {
  type        = number
  default     = 70
  description = "Priority for PHP Application rule set"
}

variable "enable_wordpress_app" {
  type        = bool
  default     = false
  description = "Enable WordPress Application rule set"
}

variable "wordpress_app_priority" {
  type        = number
  default     = 80
  description = "Priority for WordPress Application rule set"
}

variable "enable_amazon_ip_reputation" {
  type        = bool
  default     = true
  description = "Enable Amazon IP Reputation list (blocks IPs with poor reputation)"
}

variable "amazon_ip_reputation_priority" {
  type        = number
  default     = 90
  description = "Priority for Amazon IP Reputation list"
}

variable "enable_anonymous_ip_list" {
  type        = bool
  default     = false
  description = "Enable Anonymous IP list (blocks VPNs, proxies, Tor)"
}

variable "anonymous_ip_list_priority" {
  type        = number
  default     = 100
  description = "Priority for Anonymous IP list"
}

variable "enable_bot_control" {
  type        = bool
  default     = false
  description = "Enable Bot Control (requires additional charges)"
}

variable "bot_control_priority" {
  type        = number
  default     = 110
  description = "Priority for Bot Control"
}

variable "bot_control_inspection_level" {
  type        = string
  default     = "COMMON"
  description = "Bot Control inspection level (COMMON or TARGETED)"

  validation {
    condition     = contains(["COMMON", "TARGETED"], var.bot_control_inspection_level)
    error_message = "Bot Control inspection level must be COMMON or TARGETED"
  }
}

# -----------------------------------------------------------------------------
# Custom Rules - IP Sets
# -----------------------------------------------------------------------------
variable "ip_allowlist" {
  type        = list(string)
  default     = []
  description = "List of IP addresses or CIDR blocks to always allow"
}

variable "ip_allowlist_priority" {
  type        = number
  default     = 5
  description = "Priority for IP allowlist rule"
}

variable "ip_blocklist" {
  type        = list(string)
  default     = []
  description = "List of IP addresses or CIDR blocks to block"
}

variable "ip_blocklist_priority" {
  type        = number
  default     = 6
  description = "Priority for IP blocklist rule"
}

# -----------------------------------------------------------------------------
# Custom Rules - Rate Limiting
# -----------------------------------------------------------------------------
variable "enable_rate_limiting" {
  type        = bool
  default     = false
  description = "Enable rate limiting rule"
}

variable "rate_limit" {
  type        = number
  default     = 2000
  description = "Maximum number of requests allowed in 5-minute period from a single IP"
}

variable "rate_limit_priority" {
  type        = number
  default     = 7
  description = "Priority for rate limiting rule"
}

variable "rate_limit_action" {
  type        = string
  default     = "block"
  description = "Action to take when rate limit is exceeded (block or count)"

  validation {
    condition     = contains(["block", "count"], var.rate_limit_action)
    error_message = "Rate limit action must be either 'block' or 'count'"
  }
}

# -----------------------------------------------------------------------------
# Custom Rules - Geographic Blocking
# -----------------------------------------------------------------------------
variable "enable_geo_blocking" {
  type        = bool
  default     = false
  description = "Enable geographic blocking"
}

variable "geo_blocked_countries" {
  type        = list(string)
  default     = []
  description = "List of country codes to block (ISO 3166-1 alpha-2, e.g., CN, RU, KP)"
}

variable "geo_blocking_priority" {
  type        = number
  default     = 8
  description = "Priority for geographic blocking rule"
}

# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------
variable "enable_logging" {
  type        = bool
  default     = true
  description = "Enable WAF logging"
}

variable "log_destination_type" {
  type        = string
  default     = "cloudwatch"
  description = "Destination for WAF logs: cloudwatch, s3, or kinesis"

  validation {
    condition     = contains(["cloudwatch", "s3", "kinesis"], var.log_destination_type)
    error_message = "Log destination type must be cloudwatch, s3, or kinesis"
  }
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain WAF logs in CloudWatch (only used if log_destination_type is cloudwatch)"

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Must be a valid CloudWatch Logs retention value"
  }
}

variable "s3_bucket_arn" {
  type        = string
  default     = ""
  description = "S3 bucket ARN for WAF logs (only used if log_destination_type is s3)"
}

variable "kinesis_firehose_arn" {
  type        = string
  default     = ""
  description = "Kinesis Firehose ARN for WAF logs (only used if log_destination_type is kinesis)"
}

variable "redacted_fields" {
  type = list(object({
    method        = optional(bool, false)
    query_string  = optional(bool, false)
    uri_path      = optional(bool, false)
    single_header = optional(string, "")
  }))
  default     = []
  description = "Fields to redact from WAF logs for privacy/compliance"
}

# -----------------------------------------------------------------------------
# Resource Associations
# -----------------------------------------------------------------------------
variable "associated_alb_arns" {
  type        = list(string)
  default     = []
  description = "List of Application Load Balancer ARNs to associate with this Web ACL"
}

variable "associated_api_gateway_arns" {
  type        = list(string)
  default     = []
  description = "List of API Gateway stage ARNs to associate with this Web ACL"
}

variable "associated_appsync_arns" {
  type        = list(string)
  default     = []
  description = "List of AppSync GraphQL API ARNs to associate with this Web ACL"
}

variable "associated_cloudfront_distribution_ids" {
  type        = list(string)
  default     = []
  description = "List of CloudFront distribution IDs to associate with this Web ACL (only for CLOUDFRONT scope)"
}

# -----------------------------------------------------------------------------
# CloudWatch Metrics
# -----------------------------------------------------------------------------
variable "enable_cloudwatch_metrics" {
  type        = bool
  default     = true
  description = "Enable CloudWatch metrics for WAF"
}

variable "metric_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for CloudWatch metric names (defaults to Web ACL name)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for all WAF resources"
}
