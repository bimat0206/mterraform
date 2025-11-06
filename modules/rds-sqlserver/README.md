# AWS RDS SQL Server Module

Terraform module for creating and managing AWS RDS SQL Server instances with comprehensive configuration options, Secrets Manager integration, and production-ready defaults.

## Features

- **Multiple SQL Server Editions**: Support for Enterprise, Standard, Express, and Web editions
- **Secrets Manager Integration**: Complete connection information stored securely
- **Auto-managed Passwords**: RDS-managed passwords with automatic rotation support
- **High Availability**: Multi-AZ deployment support
- **Enhanced Monitoring**: CloudWatch metrics with 60-second granularity
- **Performance Insights**: Database performance monitoring (7 or 731 days retention)
- **Automated Backups**: Point-in-time recovery with 0-35 days retention
- **Storage Autoscaling**: Automatic storage expansion from 100GB to 1TB
- **Read Replicas**: Horizontal scaling with automatic replication
- **Security Groups**: Automatic security group creation with CIDR and SG-based access
- **CloudWatch Logs**: Agent and error logs exported to CloudWatch
- **Encryption**: Storage encryption with KMS support
- **Custom Configuration**: Parameter and option groups for SQL Server features

## SQL Server Editions

| Edition | Engine Value | Use Case | Features |
|---------|-------------|----------|----------|
| Enterprise | `sqlserver-ee` | Large-scale applications | All features, unlimited compute |
| Standard | `sqlserver-se` | General production workloads | Core features, limited by license |
| Express | `sqlserver-ex` | Development/testing | Free, 10GB database limit |
| Web | `sqlserver-web` | Web hosting | Low-cost, web workloads only |

## Version Support

- SQL Server 2019 (15.00)
- SQL Server 2022 (16.00)

## Usage

### Basic Example

```hcl
module "sqlserver" {
  source = "../modules/rds-sqlserver"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "app"
  identifier  = "01"

  # Network
  vpc_id     = "vpc-xxxxx"
  subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]

  # Instance
  engine         = "sqlserver-se"  # Standard Edition
  engine_version = "15.00.4335.1.v1"
  instance_class = "db.t3.xlarge"
  multi_az       = true

  # Storage
  allocated_storage     = 100
  max_allocated_storage = 500

  # Security
  allowed_cidr_blocks = ["10.0.0.0/8"]

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60

  tags = {
    Project = "MyApp"
  }
}
```

### Advanced Example with Options

```hcl
module "sqlserver_enterprise" {
  source = "../modules/rds-sqlserver"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "erp"
  service     = "database"
  identifier  = "01"

  # Network
  vpc_id     = "vpc-xxxxx"
  subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]

  # Instance
  engine                = "sqlserver-ee"  # Enterprise Edition
  engine_version        = "16.00.4095.4.v1"  # SQL Server 2022
  major_engine_version  = "16.00"
  instance_class        = "db.r6i.2xlarge"
  multi_az              = true
  license_model         = "license-included"

  # Storage
  allocated_storage     = 500
  max_allocated_storage = 2000
  storage_type          = "gp3"
  iops                  = 12000
  storage_throughput    = 500

  # Security
  allowed_security_group_ids = ["sg-xxxxx"]
  deletion_protection        = true

  # Backup
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Monitoring
  performance_insights_enabled          = true
  performance_insights_retention_period = 731  # Long-term retention
  monitoring_interval                   = 15   # 15-second granularity

  # SQL Server Options
  create_option_group = true
  options = [
    {
      option_name = "SQLSERVER_AUDIT"
      option_settings = [
        {
          name  = "S3_BUCKET_ARN"
          value = "arn:aws:s3:::my-audit-bucket"
        }
      ]
    }
  ]

  # Read Replicas
  create_read_replica = true
  read_replica_count  = 2

  tags = {
    Project     = "ERP System"
    CostCenter  = "IT"
    Compliance  = "SOC2"
  }
}
```

## SQL Server-Specific Configuration

### Timezone

```hcl
timezone = "Eastern Standard Time"
```

### Collation

```hcl
character_set_name = "SQL_Latin1_General_CP1_CI_AS"
```

### Option Groups

Common SQL Server options:

```hcl
options = [
  {
    option_name = "SQLSERVER_AUDIT"
    option_settings = [
      {
        name  = "S3_BUCKET_ARN"
        value = "arn:aws:s3:::audit-logs"
      }
    ]
  },
  {
    option_name = "TDE"  # Transparent Data Encryption
    option_settings = []
  }
]
```

## Secrets Manager Integration

The module creates a comprehensive connection secret containing:

```json
{
  "username": "sqladmin",
  "password": "<rds_managed_password>",
  "engine": "sqlserver-se",
  "host": "myorg-prod-app-sqlserver-01.xxxxx.us-east-1.rds.amazonaws.com",
  "port": 1433,
  "dbname": "myapp",
  "endpoint": "myorg-prod-app-sqlserver-01.xxxxx.us-east-1.rds.amazonaws.com:1433"
}
```

### Retrieve Connection Information

```bash
# Get complete connection info
aws secretsmanager get-secret-value \
  --secret-id myorg-prod-app-sqlserver-01-connection \
  --query SecretString --output text | jq .

# Get password only
aws secretsmanager get-secret-value \
  --secret-id myorg-prod-app-sqlserver-01-connection \
  --query SecretString --output text | jq -r '.password'
```

## Connection Methods

### sqlcmd (Command Line)

```bash
sqlcmd -S <endpoint> -U sqladmin -P <password> -d myapp
```

### ADO.NET Connection String

```
Server=<endpoint>;Database=myapp;User Id=sqladmin;Password=<password>;Encrypt=True;TrustServerCertificate=False;
```

### ODBC Connection String

```
Driver={ODBC Driver 18 for SQL Server};Server=<endpoint>;Database=myapp;Uid=sqladmin;Pwd=<password>;Encrypt=yes;
```

## Instance Class Guidelines

### Minimum Requirements

- **Express Edition**: db.t3.small (2 vCPU, 2 GB RAM)
- **Web Edition**: db.t3.small (2 vCPU, 2 GB RAM)
- **Standard Edition**: db.t3.xlarge (4 vCPU, 16 GB RAM)
- **Enterprise Edition**: db.t3.xlarge (4 vCPU, 16 GB RAM)

### Production Recommendations

- **Development**: db.t3.xlarge (~$200/month)
- **Small Production**: db.r6i.xlarge (~$600/month)
- **Medium Production**: db.r6i.2xlarge (~$1,200/month)
- **Large Production**: db.r6i.4xlarge+ (~$2,400+/month)

## Storage Configuration

### Storage Types

- **gp3**: General purpose SSD (default, 3,000-16,000 IOPS)
- **gp2**: Previous generation SSD
- **io1/io2**: Provisioned IOPS SSD (high performance)

### Storage Limits

- **Minimum**: 20 GB
- **Maximum**: 16,384 GB (16 TB)

## CloudWatch Logs

SQL Server exports two log types:

- **agent**: SQL Server Agent logs
- **error**: SQL Server error logs

## Limitations

1. **Username Restrictions**: Cannot use `admin`, `administrator`, `sa`, or `root`
2. **Multi-AZ**: Not supported for Express and Web editions
3. **Read Replicas**: Not supported for Express edition
4. **Instance Size**: Minimum db.t3.xlarge for Standard/Enterprise editions
5. **Storage**: Minimum 20 GB, recommended 100 GB for production

## Cost Optimization

1. Use **Express Edition** for development (~$15/month)
2. Use **Web Edition** for non-production web apps (~$25/month)
3. Enable storage autoscaling to avoid over-provisioning
4. Use Single-AZ for development environments
5. Consider Reserved Instances for production (up to 69% savings)

## Outputs

| Output | Description |
|--------|-------------|
| `connection_secret_arn` | ARN of the complete connection secret |
| `connection_secret_name` | Name of the connection secret |
| `db_instance_endpoint` | RDS endpoint (hostname:port) |
| `db_instance_address` | RDS hostname |
| `db_instance_port` | Database port (1433) |
| `sqlcmd_command` | Command to connect via sqlcmd |
| `retrieve_connection_info_command` | AWS CLI command to get credentials |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## License Model

- **license-included**: License included in AWS pricing (default)
- **bring-your-own-license**: Use your own SQL Server license (BYOL)

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## References

- [AWS RDS for SQL Server Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html)
- [SQL Server on RDS Pricing](https://aws.amazon.com/rds/sqlserver/pricing/)
- [RDS SQL Server Version Support](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.VersionSupport)
