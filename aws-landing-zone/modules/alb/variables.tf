variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the ALB name"
  type        = string
  default     = "pb-app"
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs where the ALB will be created"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name to use for the security group if create_security_group is true"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "List of security group IDs to use if not creating a security group"
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Whether to create security group for ALB"
  type        = bool
  default     = true
}

variable "security_group_rules" {
  description = "Security group rules to add to the security group created"
  type = object({
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
      description     = optional(string)
    }))
    egress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
      description     = optional(string)
    }))
  })
  default = {
    ingress = []
    egress  = []
  }
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Whether HTTP/2 is enabled in the load balancer"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid header fields"
  type        = bool
  default     = false
}

variable "preserve_host_header" {
  description = "Preserve host header"
  type        = bool
  default     = false
}

variable "access_logs_enabled" {
  description = "Whether to enable access logs"
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs (if empty, a new bucket will be created)"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 bucket prefix for ALB access logs"
  type        = string
  default     = "alb-logs"
}

variable "target_groups" {
  description = "Target group configurations"
  type = list(object({
    name        = string
    port        = number
    protocol    = string
    target_type = string
    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 3)
      interval            = optional(number, 30)
      matcher             = optional(string, "200")
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      timeout             = optional(number, 5)
      unhealthy_threshold = optional(number, 3)
    }))
    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
    }))
  }))
  default = []
}

variable "http_tcp_listeners" {
  description = "HTTP listener configurations"
  type = list(object({
    port     = number
    protocol = string
    default_action = object({
      type = string
      redirect = optional(object({
        port        = optional(string)
        protocol    = optional(string)
        status_code = optional(string)
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = optional(string)
      }))
      target_group_key = optional(string)
    })
  }))
  default = []
}

variable "https_listeners" {
  description = "HTTPS listener configurations"
  type = list(object({
    port            = number
    protocol        = string
    ssl_policy      = optional(string)
    certificate_arn = string
    default_action = object({
      type = string
      redirect = optional(object({
        port        = optional(string)
        protocol    = optional(string)
        status_code = optional(string)
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = optional(string)
      }))
      target_group_key = optional(string)
    })
  }))
  default = []
}

variable "https_listener_rules" {
  description = "HTTPS listener rule configurations"
  type = list(object({
    listener_index = number
    priority       = optional(number)
    actions = list(object({
      type             = string
      target_group_arn = optional(string)
      target_group_key = optional(string)
      redirect = optional(object({
        port        = optional(string)
        protocol    = optional(string)
        status_code = optional(string)
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = optional(string)
      }))
    }))
    conditions = list(object({
      host_header = optional(object({
        values = list(string)
      }))
      path_pattern = optional(object({
        values = list(string)
      }))
      http_header = optional(object({
        http_header_name = string
        values           = list(string)
      }))
      query_string = optional(list(object({
        key   = optional(string)
        value = string
      })))
      http_request_method = optional(object({
        values = list(string)
      }))
      source_ip = optional(object({
        values = list(string)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "princebank"
}

variable "cost_center" {
  description = "Cost center for the resource"
  type        = string
  default     = "landing-zone"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "landing-zone"
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  type        = string
  default     = "ipv4"
}

variable "load_balancer_create_timeout" {
  description = "Timeout value when creating the ALB"
  type        = string
  default     = "10m"
}

variable "load_balancer_update_timeout" {
  description = "Timeout value when updating the ALB"
  type        = string
  default     = "10m"
}

variable "load_balancer_delete_timeout" {
  description = "Timeout value when deleting the ALB"
  type        = string
  default     = "10m"
}

variable "ssl_policy" {
  description = "Name of the SSL Policy for the listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "default_ssl_certificate_arn" {
  description = "The ARN of the default SSL server certificate"
  type        = string
  default     = null
}

variable "connection_logs_enabled" {
  description = "Whether to enable connection logs to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "connection_logs_retention" {
  description = "Number of days to retain connection logs"
  type        = number
  default     = 90
}

variable "connection_logs_prefix" {
  description = "S3 bucket prefix for ALB connection logs"
  type        = string
  default     = "connection-logs"
}

variable "connection_logs_bucket" {
  description = "S3 bucket name to store the connection logs in"
  type        = string
  default     = ""
}

variable "logs_expiration_days" {
  description = "Number of days to retain logs before expiration"
  type        = number
  default     = 90
}