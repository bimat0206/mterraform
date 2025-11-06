# -----------------------------------------------------------------------------
# S3 Gateway Endpoint Outputs
# -----------------------------------------------------------------------------
output "s3_endpoint_id" {
  description = "The ID of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "s3_endpoint_arn" {
  description = "The ARN of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].arn : null
}

output "s3_endpoint_prefix_list_id" {
  description = "The prefix list ID of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].prefix_list_id : null
}

output "s3_endpoint_cidr_blocks" {
  description = "The list of CIDR blocks for the S3 service"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].cidr_blocks : []
}

output "s3_endpoint_state" {
  description = "The state of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].state : null
}

# -----------------------------------------------------------------------------
# DynamoDB Gateway Endpoint Outputs
# -----------------------------------------------------------------------------
output "dynamodb_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "dynamodb_endpoint_arn" {
  description = "The ARN of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].arn : null
}

output "dynamodb_endpoint_prefix_list_id" {
  description = "The prefix list ID of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].prefix_list_id : null
}

output "dynamodb_endpoint_cidr_blocks" {
  description = "The list of CIDR blocks for the DynamoDB service"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].cidr_blocks : []
}

output "dynamodb_endpoint_state" {
  description = "The state of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].state : null
}
