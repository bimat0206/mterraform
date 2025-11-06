# Application Load Balancer (ALB) Module

Production-ready AWS Application Load Balancer with S3 access logging enabled by default, comprehensive security features, and flexible configuration.

## Features

### Core Features
- **Application Load Balancer**: Layer 7 load balancing with advanced routing
- **S3 Access Logs**: Enabled by default with automatic bucket creation and configuration
- **Security Group**: Auto-created with configurable ingress rules
- **Target Groups**: Multiple target groups with health checks
- **Listeners**: HTTP/HTTPS listeners with flexible default actions
- **SSL/TLS**: Support for HTTPS with configurable SSL policies

### S3 Logging Features
- **Automatic S3 Bucket**: Creates and configures S3 bucket for logs
- **Bucket Policy**: Automatically grants ALB permissions to write logs
- **Encryption**: Server-side encryption (AES256) enabled by default
- **Lifecycle Policy**: Automatic transition to IA and expiration
- **Public Access Block**: All public access blocked by default
- **Versioning**: Optional versioning support
- **Connection Logs**: Beta feature support for connection-level logs

### Security Features
- **Desync Mitigation**: Protection against HTTP desync attacks (defensive mode default)
- **Invalid Headers**: Drops invalid HTTP header fields by default
- **Security Groups**: Auto-created with minimal required access
- **Deletion Protection**: Optional protection against accidental deletion
- **WAF Integration**: WAF fail-open mode support

### Advanced Features
- **HTTP/2**: Enabled by default
- **Cross-Zone Load Balancing**: Enabled by default
- **IPv6/Dual-stack**: Support for IPv4 and IPv6
- **Session Stickiness**: Configurable sticky sessions
- **Slow Start**: Gradual traffic increase for targets
- **Internal/Internet-Facing**: Supports both deployment models

## Cost Information

| Resource | Monthly Cost (ap-southeast-1) |
|----------|-------------------------------|
| ALB | ~$22.50 (730 hours × $0.0308/hour) |
| Data Processing | $0.008 per GB processed |
| S3 Storage | ~$0.023 per GB/month (Standard) |
| S3 Requests | $0.0004 per 1,000 PUT requests |

**Example**: ALB with 100GB/month traffic + 10GB logs = ~$23.73/month

## Quick Start

### Basic HTTP ALB

```hcl
module "alb" {
  source = "../modules/alb"

  # Naming
  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"
  identifier  = "01"

  # Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  # Target Group
  target_groups = [
    {
      name     = "web"
      port     = 80
      protocol = "HTTP"
      health_check = {
        path    = "/health"
        matcher = "200"
      }
    }
  ]

  # HTTP Listener
  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "web"
      }
    }
  ]

  tags = {}
}
```

### HTTPS ALB with HTTP Redirect

```hcl
module "alb_https" {
  source = "../modules/alb"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "api"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  # Target Groups
  target_groups = [
    {
      name     = "api"
      port     = 8080
      protocol = "HTTP"
      health_check = {
        path     = "/api/health"
        interval = 30
        timeout  = 5
        matcher  = "200-299"
      }
      stickiness = {
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = 86400
      }
    }
  ]

  # Listeners
  listeners = [
    # HTTP -> HTTPS redirect
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    },
    # HTTPS listener
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.certificate_arn
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      default_action = {
        type             = "forward"
        target_group_key = "api"
      }
    }
  ]

  # S3 Logging (enabled by default)
  enable_access_logs          = true
  log_bucket_lifecycle_days   = 90
  log_bucket_expiration_days  = 365

  tags = {}
}
```

### Internal ALB

```hcl
module "internal_alb" {
  source = "../modules/alb"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "internal"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  internal   = true

  target_groups = [
    {
      name        = "backend"
      port        = 8080
      protocol    = "HTTP"
      target_type = "ip"  # For ECS Fargate
    }
  ]

  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "backend"
      }
    }
  ]

  # Allow access only from VPC
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  tags = {}
}
```

### ALB with Custom S3 Bucket

```hcl
module "alb_custom_logs" {
  source = "../modules/alb"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  # Use existing S3 bucket
  create_s3_bucket = false
  s3_bucket_name   = "my-existing-logs-bucket"
  s3_bucket_prefix = "alb/prod"

  target_groups = [
    {
      name     = "app"
      port     = 80
      protocol = "HTTP"
    }
  ]

  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "app"
      }
    }
  ]

  tags = {}
}
```

### Multi-Target Group with Weighted Routing

```hcl
module "alb_blue_green" {
  source = "../modules/alb"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "app"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  # Multiple target groups
  target_groups = [
    {
      name     = "blue"
      port     = 8080
      protocol = "HTTP"
      health_check = {
        path = "/health"
      }
    },
    {
      name     = "green"
      port     = 8080
      protocol = "HTTP"
      health_check = {
        path = "/health"
      }
    }
  ]

  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "blue"
      }
    }
  ]

  # Enable connection logs (Beta)
  enable_connection_logs = true

  tags = {}
}
```

## Variables

### Naming Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| org_prefix | string | - | Organization prefix (Required) |
| environment | string | - | Environment name (Required) |
| workload | string | - | Workload name (Required) |
| service | string | null | Service override (default: "alb") |
| identifier | string | null | Unique identifier |
| tags | map(string) | {} | Additional tags |

### Network Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| vpc_id | string | - | VPC ID (Required) |
| subnet_ids | list(string) | - | Subnet IDs (min 2, Required) |
| internal | bool | false | Internal ALB (true) or internet-facing (false) |

### ALB Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| ip_address_type | string | "ipv4" | IP address type (ipv4 or dualstack) |
| enable_deletion_protection | bool | false | Enable deletion protection |
| enable_http2 | bool | true | Enable HTTP/2 |
| enable_cross_zone_load_balancing | bool | true | Enable cross-zone LB |
| idle_timeout | number | 60 | Connection idle timeout (1-4000) |
| desync_mitigation_mode | string | "defensive" | Desync mitigation mode |
| drop_invalid_header_fields | bool | true | Drop invalid headers |

### S3 Logging Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| enable_access_logs | bool | **true** | Enable access logs |
| create_s3_bucket | bool | true | Create S3 bucket |
| s3_bucket_name | string | "" | Existing bucket name |
| s3_bucket_prefix | string | "" | S3 prefix for logs |
| log_bucket_encryption | bool | true | Enable encryption |
| log_bucket_versioning | bool | false | Enable versioning |
| log_bucket_lifecycle_enabled | bool | true | Enable lifecycle |
| log_bucket_lifecycle_days | number | 90 | Days to IA transition |
| log_bucket_expiration_days | number | 365 | Days to expiration |
| force_destroy_log_bucket | bool | false | Allow force destroy |
| enable_connection_logs | bool | false | Enable connection logs (Beta) |

### Target Group Configuration

| Name | Type | Description |
|------|------|-------------|
| target_groups | list(object) | List of target group configurations |

**Target Group Object:**
- `name` (string, required): Target group name
- `port` (number, required): Target port
- `protocol` (string, required): Protocol (HTTP, HTTPS)
- `target_type` (string): Target type (instance, ip, lambda)
- `deregistration_delay` (number): Deregistration delay in seconds
- `slow_start` (number): Slow start duration in seconds
- `health_check` (object): Health check configuration
- `stickiness` (object): Session stickiness configuration

### Listener Configuration

| Name | Type | Description |
|------|------|-------------|
| listeners | list(object) | List of listener configurations |

**Listener Object:**
- `port` (number, required): Listener port
- `protocol` (string, required): Protocol (HTTP, HTTPS)
- `certificate_arn` (string): ACM certificate ARN (for HTTPS)
- `ssl_policy` (string): SSL policy name
- `default_action` (object): Default action configuration

## Outputs

### ALB Outputs

| Name | Description |
|------|-------------|
| alb_id | Load balancer ID |
| alb_arn | Load balancer ARN |
| alb_arn_suffix | ARN suffix for CloudWatch |
| alb_dns_name | DNS name |
| alb_zone_id | Route53 zone ID |
| alb_name | Load balancer name |
| alb_security_group_id | Security group ID |
| endpoint | HTTP endpoint URL |
| https_endpoint | HTTPS endpoint URL |

### Target Group Outputs

| Name | Description |
|------|-------------|
| target_group_arns | Map of TG names to ARNs |
| target_group_ids | Map of TG names to IDs |
| target_group_arn_suffixes | Map of TG names to ARN suffixes |
| target_group_names | Map of TG keys to full names |

### S3 Logging Outputs

| Name | Description |
|------|-------------|
| log_bucket_id | S3 bucket ID |
| log_bucket_arn | S3 bucket ARN |
| log_bucket_domain_name | S3 bucket domain name |
| access_logs_enabled | Whether logs are enabled |

## S3 Log Format

ALB access logs are stored in S3 with the following structure:

```
s3://bucket-name/prefix/AWSLogs/account-id/elasticloadbalancing/region/yyyy/mm/dd/
```

Each log file contains:
- Timestamp
- ELB name
- Client:port
- Target:port
- Request processing time
- Target processing time
- Response processing time
- ELB status code
- Target status code
- Received bytes
- Sent bytes
- HTTP request method
- Request URL
- HTTP version
- User agent
- SSL cipher
- SSL protocol

## Health Check Best Practices

1. **Dedicated Health Check Endpoint**: Create `/health` or `/healthz` endpoint
2. **Fast Response**: Health checks should respond within 2-3 seconds
3. **Shallow Checks**: Don't test deep dependencies
4. **Appropriate Intervals**: 30 seconds for most applications
5. **Unhealthy Threshold**: 2-3 consecutive failures before marking unhealthy

## SSL/TLS Policies

Recommended SSL policies by use case:

| Policy | Use Case |
|--------|----------|
| ELBSecurityPolicy-TLS13-1-2-2021-06 | Modern clients (recommended) |
| ELBSecurityPolicy-2016-08 | Legacy compatibility |
| ELBSecurityPolicy-FS-1-2-Res-2020-10 | Forward secrecy required |

## Security Best Practices

1. **Enable Access Logs**: Always enable for audit and troubleshooting
2. **Drop Invalid Headers**: Keep enabled for security
3. **Desync Mitigation**: Use "defensive" or "strictest" mode
4. **HTTPS Only**: Redirect HTTP to HTTPS in production
5. **Security Groups**: Restrict to necessary ports only
6. **Internal ALBs**: Use private subnets for internal services
7. **WAF**: Consider AWS WAF for additional protection

## Troubleshooting

### 503 Service Unavailable

1. Check target health: `aws elbv2 describe-target-health`
2. Verify security groups allow traffic from ALB to targets
3. Check health check configuration
4. Review target registration

### Logs Not Appearing

1. Verify S3 bucket policy allows ALB to write
2. Check `enable_access_logs = true`
3. Verify bucket name and region
4. Check ALB has been receiving traffic

### High Latency

1. Enable connection logs to analyze
2. Check target response times in access logs
3. Review health check impact
4. Consider connection draining settings

## Requirements

- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with at least 2 subnets in different AZs
- For HTTPS: ACM certificate in same region

## Related Modules

- `../vpc/` - VPC infrastructure
- `../acm/` - SSL/TLS certificates

## Examples

See `../../network-account/` for complete examples using this module.
