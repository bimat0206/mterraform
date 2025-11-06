# Changelog

All notable changes to the RDS SQL Server module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of RDS SQL Server module
- Support for all SQL Server editions (Enterprise, Standard, Express, Web)
- SQL Server 2019 (15.00) and 2022 (16.00) version support
- Comprehensive Secrets Manager integration for connection information
- RDS-managed password with automatic secret storage
- Dynamic naming convention: {org_prefix}-{environment}-{workload}-{service}-{identifier}
- Auto-created security groups with CIDR and security group-based access control
- DB subnet group with multi-AZ support
- IAM role for enhanced monitoring (60-second granularity)
- Performance Insights with 7 or 731 days retention
- Custom parameter groups for SQL Server configuration
- Custom option groups for SQL Server features (AUDIT, TDE, etc.)
- CloudWatch Logs export (agent and error logs)
- Automated backups with 0-35 days retention
- Storage autoscaling (gp3 with configurable IOPS and throughput)
- Storage encryption with KMS support
- Read replica support for horizontal scaling
- Multi-AZ deployment for high availability
- SQL Server-specific configuration (timezone, collation)
- License model selection (license-included or BYOL)
- Deletion protection option
- IAM database authentication support
- Comprehensive outputs including connection strings and CLI commands
- Secret recovery window configuration (default: 30 days)
- Dynamic naming with consistent pattern across all resources
- Comprehensive tagging support

### Features
- **Edition Support**: All four SQL Server editions supported
- **Version Flexibility**: Support for SQL Server 2019 and 2022
- **Security**: Encryption at rest, in-transit, and secure password management
- **Monitoring**: Enhanced monitoring and Performance Insights enabled by default
- **High Availability**: Multi-AZ deployment support for Standard and Enterprise editions
- **Scalability**: Storage autoscaling and read replica support
- **Compliance**: CloudWatch logging for audit and error tracking
- **Cost Optimization**: Support for Express and Web editions for lower costs

### Secret Structure
```json
{
  "username": "sqladmin",
  "password": "<rds_managed_password>",
  "engine": "sqlserver-se|sqlserver-ee|sqlserver-ex|sqlserver-web",
  "host": "<rds_endpoint>",
  "port": 1433,
  "dbname": "<database_name>",
  "endpoint": "<rds_endpoint>:1433"
}
```

### Default Values
- Engine: `sqlserver-se` (Standard Edition)
- Instance class: `db.t3.xlarge`
- Port: `1433`
- Storage: 100 GB gp3 with autoscaling to 1000 GB
- Backup retention: 7 days
- Multi-AZ: `false` (single-AZ)
- Monitoring interval: 60 seconds
- Performance Insights: Enabled (7 days retention)
- Encryption: Enabled
- License model: `license-included`
- Master username: `sqladmin`
- Collation: `SQL_Latin1_General_CP1_CI_AS`
- Timezone: `UTC`

### Outputs
- Complete connection information secret ARN and name
- RDS instance details (ID, ARN, endpoint, address, port)
- Security group information
- Parameter and option group details
- Monitoring role ARN
- Read replica endpoints
- Connection strings for various clients
- AWS CLI commands for credential retrieval

### Notes
- Minimum instance class for Standard/Enterprise editions: db.t3.xlarge
- Express edition has 10 GB database size limit
- Multi-AZ not supported for Express and Web editions
- Read replicas not supported for Express edition
- Master username cannot be 'admin', 'administrator', 'sa', or 'root'
