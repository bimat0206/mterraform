variable "name_prefix" {
  description = "Global prefix for all resources (e.g., 'pb-network')"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC (e.g., 'shareservices')"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where endpoints will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "region" {
  description = "AWS region where endpoints will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where interface endpoints will be created"
  type        = list(string)
}

variable "route_table_ids" {
  description = "List of route table IDs for gateway endpoints"
  type        = list(string)
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
