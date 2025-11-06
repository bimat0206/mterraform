# -----------------------------------------------------------------------------
# ALB Outputs
# -----------------------------------------------------------------------------
output "alb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in Route53 records)"
  value       = aws_lb.this.zone_id
}

output "alb_name" {
  description = "The name of the load balancer"
  value       = aws_lb.this.name
}

output "alb_security_group_id" {
  description = "The ID of the security group attached to the ALB"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "alb_security_group_arn" {
  description = "The ARN of the security group attached to the ALB"
  value       = var.create_security_group ? aws_security_group.this[0].arn : null
}

# -----------------------------------------------------------------------------
# Target Group Outputs
# -----------------------------------------------------------------------------
output "target_group_arns" {
  description = "Map of target group names to ARNs"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "target_group_ids" {
  description = "Map of target group names to IDs"
  value       = { for k, v in aws_lb_target_group.this : k => v.id }
}

output "target_group_arn_suffixes" {
  description = "Map of target group names to ARN suffixes for use with CloudWatch Metrics"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn_suffix }
}

output "target_group_names" {
  description = "Map of target group keys to full names"
  value       = { for k, v in aws_lb_target_group.this : k => v.name }
}

# -----------------------------------------------------------------------------
# Listener Outputs
# -----------------------------------------------------------------------------
output "listener_arns" {
  description = "Map of listener keys to ARNs"
  value       = { for k, v in aws_lb_listener.this : k => v.arn }
}

output "listener_ids" {
  description = "Map of listener keys to IDs"
  value       = { for k, v in aws_lb_listener.this : k => v.id }
}

# -----------------------------------------------------------------------------
# S3 Logging Outputs
# -----------------------------------------------------------------------------
output "log_bucket_id" {
  description = "The ID of the S3 bucket for ALB logs"
  value       = var.create_s3_bucket && var.enable_access_logs ? aws_s3_bucket.logs[0].id : var.s3_bucket_name
}

output "log_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB logs"
  value       = var.create_s3_bucket && var.enable_access_logs ? aws_s3_bucket.logs[0].arn : null
}

output "log_bucket_domain_name" {
  description = "The domain name of the S3 bucket for ALB logs"
  value       = var.create_s3_bucket && var.enable_access_logs ? aws_s3_bucket.logs[0].bucket_domain_name : null
}

output "log_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket for ALB logs"
  value       = var.create_s3_bucket && var.enable_access_logs ? aws_s3_bucket.logs[0].bucket_regional_domain_name : null
}

output "access_logs_enabled" {
  description = "Whether access logs are enabled"
  value       = var.enable_access_logs
}

# -----------------------------------------------------------------------------
# Convenience Outputs
# -----------------------------------------------------------------------------
output "endpoint" {
  description = "The full endpoint URL of the load balancer"
  value       = "http://${aws_lb.this.dns_name}"
}

output "https_endpoint" {
  description = "The HTTPS endpoint URL of the load balancer (if HTTPS listener exists)"
  value       = contains([for l in var.listeners : l.port], 443) ? "https://${aws_lb.this.dns_name}" : null
}
