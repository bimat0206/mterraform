output "lb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.main.id
}

output "lb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_name" {
  description = "The Name tag of the ALB"
  value       = local.alb_name
}

output "target_group_arns" {
  description = "List of target group ARNs"
  value       = [for tg in aws_lb_target_group.main : tg.arn]
}

output "target_group_names" {
  description = "List of target group names"
  value       = [for tg in aws_lb_target_group.main : tg.name]
}

# Listener and rule outputs have been removed as requested

output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.alb[0].id, null)
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = try(aws_security_group.alb[0].arn, null)
}

output "security_group_name" {
  description = "The name of the security group"
  value       = try(aws_security_group.alb[0].name, null)
}

output "security_groups" {
  description = "The security groups used by the ALB"
  value       = local.security_groups
}

output "access_logs_bucket_id" {
  description = "The ID of the access logs S3 bucket"
  value       = length(aws_s3_bucket.access_logs) > 0 ? aws_s3_bucket.access_logs[0].id : null
}

output "access_logs_bucket_arn" {
  description = "The ARN of the access logs S3 bucket"
  value       = length(aws_s3_bucket.access_logs) > 0 ? aws_s3_bucket.access_logs[0].arn : null
}

output "connection_logs_bucket_id" {
  description = "The ID of the connection logs S3 bucket"
  value       = length(aws_s3_bucket.connection_logs) > 0 ? aws_s3_bucket.connection_logs[0].id : null
}

output "connection_logs_bucket_arn" {
  description = "The ARN of the connection logs S3 bucket"
  value       = length(aws_s3_bucket.connection_logs) > 0 ? aws_s3_bucket.connection_logs[0].arn : null
}
