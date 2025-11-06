# Changelog - ALB Module

All notable changes to the ALB (Application Load Balancer) module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of ALB module
- Application Load Balancer with flexible configuration
- S3 access logging **enabled by default** with automatic bucket creation
- S3 bucket with encryption, lifecycle policy, and public access block
- Automatic S3 bucket policy for ALB log delivery
- Support for both modern logging service and legacy service account
- Auto-created security group with configurable ingress rules
- Multiple target groups with comprehensive health check configuration
- Session stickiness support (lb_cookie, app_cookie)
- Slow start configuration for gradual traffic ramping
- HTTP/HTTPS listeners with flexible default actions
- Listener actions: forward, redirect, fixed-response
- SSL/TLS support with configurable SSL policies
- Beta feature: connection-level logs
- Dynamic naming based on organizational standards
- Comprehensive outputs (ALB, target groups, listeners, S3 bucket)

### Features
- **S3 Logging**: Enabled by default with automatic configuration
  - Auto-created S3 bucket with encryption (AES256)
  - Lifecycle policy: IA transition (90 days), expiration (365 days)
  - Public access blocked by default
  - Automatic bucket policy for ALB service account
  - Support for connection logs (Beta)
- **Application Load Balancer**: Layer 7 load balancing
  - HTTP/2 enabled by default
  - Cross-zone load balancing enabled
  - Desync mitigation (defensive mode default)
  - Drop invalid HTTP headers (enabled by default)
  - IPv4/dual-stack support
  - Internal or internet-facing
- **Security Group**: Auto-created with minimal access
  - HTTP (80) and HTTPS (443) ingress
  - Configurable CIDR blocks
  - All egress allowed
- **Target Groups**: Flexible configuration
  - Health checks with configurable intervals and thresholds
  - Session stickiness (cookie-based)
  - Deregistration delay
  - Slow start support
  - Instance, IP, or Lambda targets
- **Listeners**: HTTP/HTTPS support
  - Multiple listeners per ALB
  - Dynamic actions: forward, redirect, fixed-response
  - SSL/TLS with ACM integration
  - Configurable SSL policies

### Cost Information
- **ALB**: ~$22.50/month (730 hours × $0.0308/hour in ap-southeast-1)
- **Data Processing**: $0.008 per GB processed
- **S3 Storage**: ~$0.023 per GB/month (Standard)
- **S3 Requests**: $0.0004 per 1,000 PUT requests

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- VPC with at least 2 subnets in different AZs
- For HTTPS: ACM certificate in same region

### Use Cases
- Public-facing web applications
- Internal microservices (internal ALB)
- HTTPS/TLS termination
- Multi-target group deployments (blue/green, canary)
- Path-based and host-based routing
- HTTP to HTTPS redirect

### S3 Log Structure
```
s3://bucket-name/prefix/AWSLogs/account-id/elasticloadbalancing/region/yyyy/mm/dd/
```

### Security Features
- S3 bucket encryption enabled by default
- All public access blocked on log bucket
- Security group with minimal required ports
- Drop invalid HTTP headers
- Desync mitigation enabled
- Optional deletion protection
- Optional WAF integration

### Best Practices
- Access logs enabled by default for audit and troubleshooting
- Lifecycle policy for cost optimization
- Health checks configured per target group
- HTTPS recommended for production (with HTTP redirect)
- Cross-zone load balancing for high availability
- Appropriate SSL policies based on client requirements

### Example Usage

**Basic HTTP ALB:**
```hcl
module "alb" {
  source = "../modules/alb"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

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

**HTTPS with HTTP Redirect:**
```hcl
module "alb_https" {
  source = "../modules/alb"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "api"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

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
    }
  ]

  listeners = [
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

  tags = {}
}
```

### Documentation
- Comprehensive README with usage examples
- Multiple deployment scenarios
- Cost breakdown and optimization
- Security best practices
- Troubleshooting guide
- Health check recommendations
- SSL/TLS policy guidance

### Related Modules
- `../vpc/` - VPC infrastructure
- `../acm/` - SSL/TLS certificates
