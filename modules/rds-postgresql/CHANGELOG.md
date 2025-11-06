# Changelog - RDS PostgreSQL Module

## [1.0.0] - 2025-11-06

### Added
- Initial release of RDS PostgreSQL module
- PostgreSQL 15.x and 16.x support
- Multi-AZ deployment for high availability
- Read replica support (configurable count)
- Automated backups (0-35 days retention)
- RDS-managed Secrets Manager integration for passwords
- Performance Insights with 7-day retention (free tier)
- Enhanced monitoring with 60-second intervals
- CloudWatch Logs exports (postgresql, upgrade)
- Storage autoscaling (gp3 default)
- KMS encryption for data at rest
- Auto-created security groups
- Custom parameter groups
- Dynamic naming convention
- Comprehensive outputs with connection info

### Features
- Cost: Starting at ~$15/month (db.t3.micro Single-AZ)
- Storage: gp3 with 3000 IOPS, 125 MB/s throughput
- Default: Single-AZ, 20GB storage, PostgreSQL 16.1
- Security: Encrypted storage, managed passwords
- Monitoring: Performance Insights + Enhanced Monitoring
