output "ec2_endpoint_id" {
  description = "The ID of the EC2 VPC endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "ec2_endpoint_dns_entry" {
  description = "The DNS entries for the EC2 VPC endpoint"
  value       = aws_vpc_endpoint.ec2.dns_entry
}

output "ec2messages_endpoint_id" {
  description = "The ID of the EC2 Messages VPC endpoint"
  value       = aws_vpc_endpoint.ec2messages.id
}

output "ec2messages_endpoint_dns_entry" {
  description = "The DNS entries for the EC2 Messages VPC endpoint"
  value       = aws_vpc_endpoint.ec2messages.dns_entry
}

output "logs_endpoint_id" {
  description = "The ID of the CloudWatch Logs VPC endpoint"
  value       = aws_vpc_endpoint.logs.id
}

output "logs_endpoint_dns_entry" {
  description = "The DNS entries for the CloudWatch Logs VPC endpoint"
  value       = aws_vpc_endpoint.logs.dns_entry
}

output "ssm_endpoint_id" {
  description = "The ID of the SSM VPC endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_endpoint_dns_entry" {
  description = "The DNS entries for the SSM VPC endpoint"
  value       = aws_vpc_endpoint.ssm.dns_entry
}

output "elasticloadbalancing_endpoint_id" {
  description = "The ID of the Elastic Load Balancing VPC endpoint"
  value       = aws_vpc_endpoint.elasticloadbalancing.id
}

output "elasticloadbalancing_endpoint_dns_entry" {
  description = "The DNS entries for the Elastic Load Balancing VPC endpoint"
  value       = aws_vpc_endpoint.elasticloadbalancing.dns_entry
}

output "ssmmessages_endpoint_id" {
  description = "The ID of the SSM Messages VPC endpoint"
  value       = aws_vpc_endpoint.ssmmessages.id
}

output "ssmmessages_endpoint_dns_entry" {
  description = "The DNS entries for the SSM Messages VPC endpoint"
  value       = aws_vpc_endpoint.ssmmessages.dns_entry
}

output "s3_endpoint_id" {
  description = "The ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "s3_endpoint_dns_entry" {
  description = "The DNS entries for the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.dns_entry
}

output "vpc_endpoint_security_group_id" {
  description = "The ID of the security group created for the VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "guardduty_endpoint_id" {
  description = "The ID of the GuardDuty VPC endpoint"
  value       = aws_vpc_endpoint.guardduty.id
}

output "guardduty_endpoint_dns_entry" {
  description = "The DNS entries for the GuardDuty VPC endpoint"
  value       = aws_vpc_endpoint.guardduty.dns_entry
}
