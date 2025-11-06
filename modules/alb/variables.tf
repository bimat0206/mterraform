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
  description = "Service name override. Defaults to 'alb' if not provided"
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
  description = "VPC ID where ALB will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ALB (must be in at least 2 AZs)"
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "ALB requires at least 2 subnets in different availability zones"
  }
}

# -----------------------------------------------------------------------------
# ALB Configuration
# -----------------------------------------------------------------------------
variable "internal" {
  type        = bool
  default     = false
  description = "Create internal ALB (true) or internet-facing ALB (false)"
}

variable "ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "Type of IP addresses used by subnets (ipv4 or dualstack)"
  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be either 'ipv4' or 'dualstack'"
  }
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection on the ALB"
}

variable "enable_http2" {
  type        = bool
  default     = true
  description = "Enable HTTP/2 on the ALB"
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  default     = true
  description = "Enable cross-zone load balancing"
}

variable "idle_timeout" {
  type        = number
  default     = 60
  description = "Time in seconds that the connection is allowed to be idle"
  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "idle_timeout must be between 1 and 4000 seconds"
  }
}

variable "enable_waf_fail_open" {
  type        = bool
  default     = false
  description = "Enable WAF fail open mode"
}

variable "desync_mitigation_mode" {
  type        = string
  default     = "defensive"
  description = "Determines how the load balancer handles requests that might pose a security risk (defensive, strictest, monitor)"
  validation {
    condition     = contains(["defensive", "strictest", "monitor"], var.desync_mitigation_mode)
    error_message = "desync_mitigation_mode must be defensive, strictest, or monitor"
  }
}

variable "drop_invalid_header_fields" {
  type        = bool
  default     = true
  description = "Drop invalid HTTP header fields"
}

# -----------------------------------------------------------------------------
# Security Group Configuration
# -----------------------------------------------------------------------------
variable "create_security_group" {
  type        = bool
  default     = true
  description = "Create a security group for the ALB"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to attach (used if create_security_group = false)"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access the ALB"
}

variable "allowed_ipv6_cidr_blocks" {
  type        = list(string)
  default     = ["::/0"]
  description = "List of IPv6 CIDR blocks allowed to access the ALB"
}

# -----------------------------------------------------------------------------
# S3 Logging Configuration
# -----------------------------------------------------------------------------
variable "enable_access_logs" {
  type        = bool
  default     = true
  description = "Enable ALB access logs to S3"
}

variable "create_s3_bucket" {
  type        = bool
  default     = true
  description = "Create S3 bucket for ALB logs (if false, use existing bucket)"
}

variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "Name of existing S3 bucket for logs (used if create_s3_bucket = false)"
}

variable "s3_bucket_prefix" {
  type        = string
  default     = ""
  description = "S3 bucket prefix for ALB logs"
}

variable "log_bucket_encryption" {
  type        = bool
  default     = true
  description = "Enable server-side encryption for S3 log bucket"
}

variable "log_bucket_versioning" {
  type        = bool
  default     = false
  description = "Enable versioning for S3 log bucket"
}

variable "log_bucket_lifecycle_enabled" {
  type        = bool
  default     = true
  description = "Enable lifecycle policy for S3 log bucket"
}

variable "log_bucket_lifecycle_days" {
  type        = number
  default     = 90
  description = "Number of days to retain logs before transitioning to IA"
}

variable "log_bucket_expiration_days" {
  type        = number
  default     = 365
  description = "Number of days to retain logs before deletion"
}

variable "force_destroy_log_bucket" {
  type        = bool
  default     = false
  description = "Allow deletion of non-empty S3 log bucket"
}

# -----------------------------------------------------------------------------
# Target Group Configuration
# -----------------------------------------------------------------------------
variable "target_groups" {
  type = list(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = optional(string, "instance")
    deregistration_delay = optional(number, 300)
    slow_start           = optional(number, 0)
    health_check = optional(object({
      enabled             = optional(bool, true)
      interval            = optional(number, 30)
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 2)
      matcher             = optional(string, "200")
    }), {})
    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
      cookie_name     = optional(string, null)
    }), {})
  }))
  default     = []
  description = "List of target group configurations"
}

# -----------------------------------------------------------------------------
# Listener Configuration
# -----------------------------------------------------------------------------
variable "listeners" {
  type = list(object({
    port            = number
    protocol        = string
    certificate_arn = optional(string, null)
    ssl_policy      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    default_action = object({
      type             = string
      target_group_key = optional(string, null)
      redirect = optional(object({
        protocol    = optional(string, "HTTPS")
        port        = optional(string, "443")
        status_code = string
      }), null)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string, null)
        status_code  = string
      }), null)
    })
  }))
  default     = []
  description = "List of listener configurations"
}

# -----------------------------------------------------------------------------
# Connection Logs (Beta)
# -----------------------------------------------------------------------------
variable "enable_connection_logs" {
  type        = bool
  default     = false
  description = "Enable ALB connection logs to S3 (Beta feature)"
}
