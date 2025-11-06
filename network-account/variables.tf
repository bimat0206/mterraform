# -----------------------------------------------------------------------------
# General configuration
# -----------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS region where resources will be created"
}

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

# -----------------------------------------------------------------------------
# Tagging
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# VPC Basic Configuration
# -----------------------------------------------------------------------------
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "vpc_secondary_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of secondary CIDR blocks to associate with the VPC"
}

variable "vpc_enable_ipv6" {
  type        = bool
  default     = false
  description = "Enable IPv6 CIDR block for the VPC"
}

variable "vpc_instance_tenancy" {
  type        = string
  default     = "default"
  description = "Tenancy option for instances launched into the VPC"
}

# -----------------------------------------------------------------------------
# DNS Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable DNS hostnames in the VPC"
}

variable "vpc_enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS support in the VPC"
}

# -----------------------------------------------------------------------------
# Subnet Configuration
# -----------------------------------------------------------------------------
variable "vpc_az_count" {
  type        = number
  default     = 2
  description = "Number of Availability Zones for VPC subnets"
}

variable "vpc_public_subnet_suffix" {
  type        = string
  default     = "public"
  description = "Suffix for public subnet names"
}

variable "vpc_private_subnet_suffix" {
  type        = string
  default     = "private"
  description = "Suffix for private subnet names"
}

variable "vpc_database_subnet_suffix" {
  type        = string
  default     = "database"
  description = "Suffix for database subnet names"
}

variable "vpc_create_database_subnets" {
  type        = bool
  default     = false
  description = "Create dedicated database subnets"
}

variable "vpc_create_database_subnet_group" {
  type        = bool
  default     = false
  description = "Create database subnet group"
}

variable "vpc_map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Auto-assign public IP on launch for instances in public subnets"
}

# -----------------------------------------------------------------------------
# NAT Gateway Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway for VPC private subnets"
}

variable "vpc_single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use a single NAT Gateway for all private subnets"
}

variable "vpc_one_nat_gateway_per_az" {
  type        = bool
  default     = false
  description = "Create one NAT Gateway per AZ for high availability"
}

# -----------------------------------------------------------------------------
# VPN Gateway Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "Enable VPN Gateway"
}

variable "vpc_vpn_gateway_az" {
  type        = string
  default     = null
  description = "Availability Zone for the VPN Gateway"
}

variable "vpc_propagate_vpn_routes_to_private_route_tables" {
  type        = bool
  default     = false
  description = "Propagate VPN routes to private route tables"
}

variable "vpc_propagate_vpn_routes_to_public_route_tables" {
  type        = bool
  default     = false
  description = "Propagate VPN routes to public route tables"
}

# -----------------------------------------------------------------------------
# VPC Flow Logs Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_flow_logs" {
  type        = bool
  default     = false
  description = "Enable VPC Flow Logs"
}

variable "vpc_flow_logs_destination_type" {
  type        = string
  default     = "cloud-watch-logs"
  description = "Type of flow logs destination"
}

variable "vpc_flow_logs_destination_arn" {
  type        = string
  default     = ""
  description = "ARN of CloudWatch Log Group or S3 bucket for flow logs"
}

variable "vpc_flow_logs_traffic_type" {
  type        = string
  default     = "ALL"
  description = "Type of traffic to log"
}

variable "vpc_flow_logs_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log group retention in days"
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# VPC Gateway Endpoints Configuration
# -----------------------------------------------------------------------------
variable "vpce_gateway_enabled" {
  type        = bool
  default     = false
  description = "Enable VPC Gateway Endpoints module"
}

variable "vpce_enable_s3_endpoint" {
  type        = bool
  default     = true
  description = "Enable S3 VPC Gateway Endpoint (FREE)"
}

variable "vpce_enable_dynamodb_endpoint" {
  type        = bool
  default     = false
  description = "Enable DynamoDB VPC Gateway Endpoint (FREE)"
}

# -----------------------------------------------------------------------------
# VPC Interface Endpoints Configuration
# -----------------------------------------------------------------------------
variable "vpce_interface_enabled" {
  type        = bool
  default     = false
  description = "Enable VPC Interface Endpoints module"
}

variable "vpce_interface_endpoints" {
  type        = map(bool)
  default     = {}
  description = "Map of AWS services to create interface endpoints for (e.g., { ec2 = true, ssm = true })"
}

variable "vpce_private_dns_enabled" {
  type        = bool
  default     = true
  description = "Enable private DNS for interface endpoints"
}

# -----------------------------------------------------------------------------
# DHCP Options Configuration
# -----------------------------------------------------------------------------
variable "vpc_enable_dhcp_options" {
  type        = bool
  default     = false
  description = "Enable custom DHCP options"
}

variable "vpc_dhcp_options_domain_name" {
  type        = string
  default     = ""
  description = "Domain name for DHCP options"
}

variable "vpc_dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "List of name servers for DHCP options"
}

variable "vpc_dhcp_options_ntp_servers" {
  type        = list(string)
  default     = []
  description = "List of NTP servers for DHCP options"
}

variable "vpc_dhcp_options_netbios_name_servers" {
  type        = list(string)
  default     = []
  description = "List of NetBIOS name servers for DHCP options"
}

variable "vpc_dhcp_options_netbios_node_type" {
  type        = number
  default     = 2
  description = "NetBIOS node type for DHCP options"
}

# -----------------------------------------------------------------------------
# Network ACL Configuration
# -----------------------------------------------------------------------------
variable "vpc_manage_default_network_acl" {
  type        = bool
  default     = false
  description = "Manage the default network ACL"
}

variable "vpc_default_network_acl_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of ingress rules for default network ACL"
}

variable "vpc_default_network_acl_egress" {
  type        = list(map(string))
  default     = []
  description = "List of egress rules for default network ACL"
}

variable "vpc_public_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Create dedicated network ACL for public subnets"
}

variable "vpc_private_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Create dedicated network ACL for private subnets"
}

# -----------------------------------------------------------------------------
# Default Security Group Configuration
# -----------------------------------------------------------------------------
variable "vpc_manage_default_security_group" {
  type        = bool
  default     = false
  description = "Manage the default security group"
}

variable "vpc_default_security_group_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of ingress rules for default security group"
}

variable "vpc_default_security_group_egress" {
  type        = list(map(string))
  default     = []
  description = "List of egress rules for default security group"
}

# -----------------------------------------------------------------------------
# Default Route Table Configuration
# -----------------------------------------------------------------------------
variable "vpc_manage_default_route_table" {
  type        = bool
  default     = false
  description = "Manage the default route table"
}

variable "vpc_default_route_table_routes" {
  type        = list(map(string))
  default     = []
  description = "List of routes for default route table"
}

# -----------------------------------------------------------------------------
# ACM Configuration
# -----------------------------------------------------------------------------
variable "acm_domain_name" {
  type        = string
  description = "Primary domain name for ACM certificate"
  default     = ""
}

variable "acm_subject_alternative_names" {
  type        = list(string)
  description = "Subject Alternative Names (SANs) for ACM certificate"
  default     = []
}

variable "acm_hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for ACM DNS validation"
  default     = ""
}

variable "acm_enabled" {
  type        = bool
  description = "Whether to create ACM certificate"
  default     = false
}

# -----------------------------------------------------------------------------
# ALB Configuration
# -----------------------------------------------------------------------------
variable "alb_enabled" {
  type        = bool
  description = "Whether to create Application Load Balancer"
  default     = false
}

variable "alb_internal" {
  type        = bool
  default     = false
  description = "Whether the ALB is internal (true) or internet-facing (false)"
}

variable "alb_enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable deletion protection for the ALB"
}

variable "alb_enable_http2" {
  type        = bool
  default     = true
  description = "Enable HTTP/2 on the ALB"
}

variable "alb_enable_cross_zone_load_balancing" {
  type        = bool
  default     = true
  description = "Enable cross-zone load balancing"
}

variable "alb_idle_timeout" {
  type        = number
  default     = 60
  description = "Time in seconds that the connection is allowed to be idle"
}

variable "alb_drop_invalid_header_fields" {
  type        = bool
  default     = true
  description = "Drop invalid HTTP header fields"
}

variable "alb_enable_access_logs" {
  type        = bool
  default     = true
  description = "Enable access logs for the ALB"
}

variable "alb_create_s3_bucket" {
  type        = bool
  default     = true
  description = "Create S3 bucket for ALB logs"
}

variable "alb_s3_bucket_prefix" {
  type        = string
  default     = "alb-logs"
  description = "Prefix for ALB logs in S3 bucket"
}

variable "alb_log_bucket_lifecycle_days" {
  type        = number
  default     = 90
  description = "Days before transitioning logs to Infrequent Access storage"
}

variable "alb_log_bucket_expiration_days" {
  type        = number
  default     = 365
  description = "Days before expiring/deleting logs"
}

variable "alb_target_groups" {
  type = list(object({
    name     = string
    port     = number
    protocol = string
    target_type = optional(string, "instance")
    deregistration_delay = optional(number, 300)
    slow_start = optional(number, 0)
    health_check = optional(object({
      enabled             = optional(bool, true)
      interval            = optional(number, 30)
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, "200")
    }), {})
    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
      cookie_name     = optional(string, "")
    }), {})
  }))
  default     = []
  description = "List of target groups to create for the ALB"
}

variable "alb_listeners" {
  type = list(object({
    port            = number
    protocol        = string
    certificate_arn = optional(string, "")
    ssl_policy      = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    default_action = object({
      type             = string
      target_group_key = optional(string, "")
      redirect = optional(object({
        protocol    = optional(string, "HTTPS")
        port        = optional(string, "443")
        status_code = string
      }), null)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string, "")
        status_code  = string
      }), null)
    })
  }))
  default     = []
  description = "List of listeners to create for the ALB"
}

variable "alb_security_group_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from anywhere"
    }
  ]
  description = "List of ingress rules for ALB security group"
}
