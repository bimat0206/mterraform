# RDS PostgreSQL Module

Terraform module for deploying production-ready PostgreSQL RDS instances with comprehensive features including Multi-AZ, read replicas, automated backups, Performance Insights, and Secrets Manager integration.

## Features

- **PostgreSQL 15 & 16** support
- **Multi-AZ** deployment for high availability
- **Read Replicas** for horizontal scaling
- **Automated Backups** with configurable retention (0-35 days)
- **Secrets Manager** integration for password management
- **Performance Insights** with configurable retention
- **Enhanced Monitoring** with CloudWatch metrics
- **Storage Autoscaling** with gp3 (default)
- **Encryption** at rest with KMS
- **CloudWatch Logs** export (postgresql, upgrade)
- **Dynamic Naming** convention support
- **Security Groups** with CIDR and SG-based access control
- **Parameter Groups** for custom database configuration

## Quick Start

```hcl
module "postgres" {
  source = "../modules/rds-postgresql"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "api"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  engine_version    = "16.1"

  allowed_cidr_blocks = ["10.0.0.0/8"]
  multi_az            = true

  tags = {}
}
```

## Cost Estimation

- db.t3.micro: ~$15/month (Single-AZ), ~$30/month (Multi-AZ)
- db.t3.small: ~$30/month (Single-AZ), ~$60/month (Multi-AZ)
- db.r6g.large: ~$146/month (Single-AZ), ~$292/month (Multi-AZ)
- Storage (gp3): ~$0.092/GB-month
- Backup Storage: $0.095/GB-month (after free tier)
- Performance Insights: Free (7 days), $0.0116/vCPU-hour (long-term)

## Requirements

- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with at least 2 subnets in different AZs

## Usage Examples

See variables.tf for all configuration options.
