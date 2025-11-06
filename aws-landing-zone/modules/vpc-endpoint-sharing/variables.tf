variable "name_prefix" {
  description = "Global prefix for all resources (e.g., 'pb-network')"
  type        = string
  default     = ""
}

variable "shared_vpc_name" {
  description = "Name of the shared services VPC (e.g., 'shareservices')"
  type        = string
}

variable "shared_vpc_id" {
  description = "ID of the shared services VPC where endpoints are created"
  type        = string
}

variable "region" {
  description = "AWS region where endpoints are created"
  type        = string
}

variable "consumer_vpc_ids" {
  description = "List of consumer VPC IDs that will access the shared endpoints"
  type        = list(string)
}

# VPC Endpoint IDs to be shared
variable "ec2_endpoint_id" {
  description = "ID of the EC2 VPC endpoint"
  type        = string
  default     = ""
}

variable "ec2messages_endpoint_id" {
  description = "ID of the EC2 Messages VPC endpoint"
  type        = string
  default     = ""
}

variable "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  type        = string
  default     = ""
}

variable "ssm_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  type        = string
  default     = ""
}

variable "elasticloadbalancing_endpoint_id" {
  description = "ID of the Elastic Load Balancing VPC endpoint"
  type        = string
  default     = ""
}

variable "ssmmessages_endpoint_id" {
  description = "ID of the SSM Messages VPC endpoint"
  type        = string
  default     = ""
}

variable "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  type        = string
  default     = ""
}

variable "guardduty_endpoint_id" {
  description = "ID of the GuardDuty VPC endpoint"
  type        = string
  default     = ""
}

variable "create_guardduty_endpoint_zone" {
  description = "Whether to create the private hosted zone for the GuardDuty endpoint. Set to true if the GuardDuty endpoint is enabled."
  type        = bool
  default     = false
}

variable "create_s3_endpoint_zone" {
  description = "Whether to create the private hosted zone for the S3 endpoint. Set to true if the S3 endpoint is enabled."
  type        = bool
  default     = true
}

variable "ec2_endpoint_dns_entry" {
  description = "DNS entries for the EC2 VPC endpoint"
  type        = list(map(string))
}

variable "ec2messages_endpoint_dns_entry" {
  description = "DNS entries for the EC2 Messages VPC endpoint"
  type        = list(map(string))
}

variable "logs_endpoint_dns_entry" {
  description = "DNS entries for the CloudWatch Logs VPC endpoint"
  type        = list(map(string))
}

variable "ssm_endpoint_dns_entry" {
  description = "DNS entries for the SSM VPC endpoint"
  type        = list(map(string))
}

variable "elasticloadbalancing_endpoint_dns_entry" {
  description = "DNS entries for the Elastic Load Balancing VPC endpoint"
  type        = list(map(string))
}

variable "ssmmessages_endpoint_dns_entry" {
  description = "DNS entries for the SSM Messages VPC endpoint"
  type        = list(map(string))
}

variable "s3_endpoint_dns_entry" {
  description = "DNS entries for the S3 VPC endpoint"
  type        = list(map(string))
}

variable "guardduty_endpoint_dns_entry" {
  description = "DNS entries for the GuardDuty VPC endpoint"
  type        = list(map(string))
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "princebank"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "landing-zone"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "landing-zone"
}

variable "skip_existing_associations" {
  type        = bool
  description = "Whether to skip creating zone associations if they already exist (to prevent conflicting associations)."
  default     = false
}
