# AWS WAF Module

Terraform module for creating and managing AWS WAFv2 (Web Application Firewall) Web ACLs with comprehensive protection, AWS Managed Rules, custom rules, and resource associations.

## Features

- **AWS Managed Rule Groups**: Toggle on/off for 11 different AWS-managed rule sets
- **Custom Rules**: IP allowlist/blocklist, rate limiting, geographic blocking
- **Resource Associations**: ALB, API Gateway, AppSync, CloudFront support
- **Comprehensive Logging**: CloudWatch Logs, S3, or Kinesis Firehose
- **CloudWatch Metrics**: Real-time monitoring and alerting
- **Modular Design**: Organized into separate files for easier troubleshooting
- **Flexible Configuration**: Granular control over every rule and setting
- **Production Ready**: Best practices for web application security

## Architecture

The module is organized into separate files for better maintainability:

- **data.tf**: Data sources, locals, and managed rule configurations
- **waf.tf**: Web ACL with all rules
- **custom_rules.tf**: IP sets for allowlist/blocklist
- **logging.tf**: CloudWatch Logs and logging configuration
- **associations.tf**: Resource associations (ALB, API Gateway, AppSync)
- **versions.tf**: Provider version constraints
- **variables.tf**: Input variables (100+ configuration options)
- **outputs.tf**: Output values and management commands

## Usage

### Basic Example - REGIONAL WAF for ALB

```hcl
module "waf_regional" {
  source = "../modules/waf"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "app"
  identifier  = "01"

  # WAF Configuration
  scope          = "REGIONAL"
  default_action = "allow"

  # Enable AWS Managed Rules (default: true)
  enable_aws_managed_rules = true
  enable_core_rule_set     = true
  enable_known_bad_inputs  = true
  enable_sql_injection     = true

  # Associate with ALB
  associated_alb_arns = [
    "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9188"
  ]

  tags = {
    Project = "WebApp"
  }
}
```

### Complete Example - Maximum Protection

```hcl
module "waf_complete" {
  source = "../modules/waf"

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "api"
  service     = "waf"
  identifier  = "01"

  # WAF Configuration
  scope          = "REGIONAL"
  default_action = "allow"
  description    = "Production API WAF with comprehensive protection"

  # AWS Managed Rules - Enable All
  enable_aws_managed_rules   = true
  enable_core_rule_set       = true  # OWASP Top 10
  enable_known_bad_inputs    = true  # Known malicious patterns
  enable_sql_injection       = true  # SQL injection protection
  enable_amazon_ip_reputation = true  # Bad IP reputation
  enable_linux_os            = false # Enable if Linux backend
  enable_unix_os             = false
  enable_windows_os          = false # Enable if Windows backend
  enable_php_app             = false # Enable if PHP app
  enable_wordpress_app       = false # Enable if WordPress

  # Bot Control (additional charges apply)
  enable_bot_control             = true
  bot_control_inspection_level   = "COMMON"  # or "TARGETED"

  # Anonymous IP blocking (blocks VPNs, proxies, Tor)
  enable_anonymous_ip_list = true

  # Custom Rules - IP Management
  ip_allowlist = [
    "203.0.113.0/24",      # Office IP range
    "198.51.100.50/32"     # Partner IP
  ]
  ip_blocklist = [
    "192.0.2.100/32",      # Malicious IP
    "198.51.100.0/24"      # Blocked range
  ]

  # Rate Limiting
  enable_rate_limiting = true
  rate_limit           = 2000  # Max 2000 requests per 5 minutes per IP
  rate_limit_action    = "block"

  # Geographic Blocking
  enable_geo_blocking     = true
  geo_blocked_countries   = ["CN", "RU", "KP"]  # ISO 3166-1 alpha-2

  # Logging to CloudWatch
  enable_logging       = true
  log_destination_type = "cloudwatch"
  log_retention_days   = 30

  # Redact sensitive data from logs
  redacted_fields = [
    {
      single_header = "authorization"
    },
    {
      single_header = "cookie"
    }
  ]

  # CloudWatch Metrics
  enable_cloudwatch_metrics = true

  # Associate with multiple ALBs
  associated_alb_arns = [
    module.alb_api.alb_arn,
    module.alb_web.alb_arn
  ]

  # Associate with API Gateway
  associated_api_gateway_arns = [
    "${aws_api_gateway_rest_api.api.arn}/stages/${aws_api_gateway_stage.prod.stage_name}"
  ]

  tags = {
    Project     = "API"
    CostCenter  = "Engineering"
    Compliance  = "PCI-DSS"
  }
}
```

### CloudFront WAF Example

```hcl
# Note: CloudFront WAF must be created in us-east-1 region
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "waf_cloudfront" {
  source = "../modules/waf"

  providers = {
    aws = aws.us_east_1
  }

  # Naming
  org_prefix  = "myorg"
  environment = "prod"
  workload    = "cdn"

  # CloudFront scope
  scope          = "CLOUDFRONT"
  default_action = "allow"

  # Enable protection
  enable_aws_managed_rules = true
  enable_core_rule_set     = true
  enable_sql_injection     = true
  enable_rate_limiting     = true
  rate_limit               = 5000

  # Note: CloudFront associations are handled in CloudFront distribution config
  # See CloudFront documentation for web_acl_id parameter

  tags = {
    Project = "CDN"
  }
}
```

### S3 Logging Example

```hcl
# Create S3 bucket for WAF logs
resource "aws_s3_bucket" "waf_logs" {
  bucket = "myorg-prod-waf-logs"
}

module "waf_with_s3_logging" {
  source = "../modules/waf"

  org_prefix  = "myorg"
  environment = "prod"
  workload    = "app"

  scope          = "REGIONAL"
  default_action = "allow"

  enable_aws_managed_rules = true
  enable_core_rule_set     = true

  # S3 Logging
  enable_logging       = true
  log_destination_type = "s3"
  s3_bucket_arn        = aws_s3_bucket.waf_logs.arn

  associated_alb_arns = [module.alb.alb_arn]

  tags = {
    Project = "WebApp"
  }
}
```

## AWS Managed Rule Groups

The module supports 11 AWS Managed Rule Groups that can be toggled on/off individually:

### Core Protection

**Core Rule Set** (`enable_core_rule_set = true`)
- Protects against OWASP Top 10 vulnerabilities
- **Recommended for all applications**
- Includes protection against: XSS, SQL injection, LFI, RFI, RCE

**Known Bad Inputs** (`enable_known_bad_inputs = true`)
- Blocks requests with known malicious patterns
- **Recommended for all applications**
- Low false positive rate

### Injection Attacks

**SQL Injection** (`enable_sql_injection = true`)
- Advanced SQL injection protection
- **Recommended if you have databases**
- Works with: MySQL, PostgreSQL, MS SQL, Oracle

### Operating System Protection

**Linux OS** (`enable_linux_os = true`)
- Protects against Linux-specific attacks
- Enable if backend runs Linux

**Unix OS** (`enable_unix_os = true`)
- Protects against Unix-specific attacks
- Enable if backend runs Unix systems

**Windows OS** (`enable_windows_os = true`)
- Protects against Windows-specific attacks
- Enable if backend runs Windows

### Application-Specific

**PHP Application** (`enable_php_app = true`)
- PHP-specific vulnerability protection
- Enable for PHP applications

**WordPress Application** (`enable_wordpress_app = true`)
- WordPress-specific protection
- Enable for WordPress sites

### IP Reputation

**Amazon IP Reputation** (`enable_amazon_ip_reputation = true`)
- Blocks IPs with poor reputation
- **Recommended for public-facing applications**
- Based on Amazon threat intelligence

**Anonymous IP List** (`enable_anonymous_ip_list = true`)
- Blocks VPNs, proxies, Tor exit nodes
- Enable if you need to block anonymous traffic
- May impact legitimate users behind VPNs

### Bot Protection

**Bot Control** (`enable_bot_control = true`)
- Advanced bot detection and mitigation
- **Additional charges apply** (~$10/month + $1 per million requests)
- Inspection levels:
  - `COMMON`: Basic bot detection (good/bad/unknown)
  - `TARGETED`: Advanced detection with bot categories

## Custom Rules

### IP Allowlist

Highest priority - always allow specific IPs:

```hcl
ip_allowlist = [
  "203.0.113.0/24",      # Office network
  "198.51.100.50/32",    # CI/CD system
  "192.0.2.10/32"        # Monitoring system
]
ip_allowlist_priority = 5  # Runs first
```

### IP Blocklist

Block malicious IPs:

```hcl
ip_blocklist = [
  "192.0.2.100/32",      # Known attacker
  "198.51.100.0/24"      # Blocked ISP range
]
ip_blocklist_priority = 6  # Runs after allowlist
```

### Rate Limiting

Protect against DDoS and abuse:

```hcl
enable_rate_limiting = true
rate_limit           = 2000  # Max requests per 5 minutes from single IP
rate_limit_action    = "block"  # or "count" for testing
```

**Common rate limits:**
- API endpoints: 1000-2000 requests/5min
- Web applications: 2000-5000 requests/5min
- Public pages: 5000-10000 requests/5min

### Geographic Blocking

Block entire countries:

```hcl
enable_geo_blocking   = true
geo_blocked_countries = [
  "CN",  # China
  "RU",  # Russia
  "KP",  # North Korea
  "IR"   # Iran
]
```

**Country codes**: Use ISO 3166-1 alpha-2 (2-letter codes)

## Resource Associations

### Application Load Balancer (ALB)

```hcl
# Associate with ALB ARN
associated_alb_arns = [
  "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9188"
]

# Or use Terraform resource reference
associated_alb_arns = [
  aws_lb.app.arn,
  module.alb.alb_arn
]
```

### API Gateway

```hcl
# Associate with API Gateway stage
associated_api_gateway_arns = [
  "${aws_api_gateway_rest_api.api.arn}/stages/${aws_api_gateway_stage.prod.stage_name}"
]

# Format: arn:aws:apigateway:region::/restapis/api-id/stages/stage-name
```

### AppSync GraphQL API

```hcl
associated_appsync_arns = [
  aws_appsync_graphql_api.api.arn
]
```

### CloudFront Distribution

CloudFront associations are handled in the CloudFront distribution configuration:

```hcl
resource "aws_cloudfront_distribution" "cdn" {
  # ... other configuration ...

  web_acl_id = module.waf_cloudfront.web_acl_arn

  # Note: Must use CLOUDFRONT scope WAF created in us-east-1
}
```

## Logging

### CloudWatch Logs (Default)

```hcl
enable_logging       = true
log_destination_type = "cloudwatch"
log_retention_days   = 7  # 1, 3, 5, 7, 14, 30, 60, 90, etc.
```

**View logs:**
```bash
# Using Terraform output
terraform output waf_view_logs_command

# Or directly
aws logs tail /aws/wafv2/myorg-prod-app-waf-01 --follow --format short

# Filter for blocked requests
aws logs filter-log-events \
  --log-group-name /aws/wafv2/myorg-prod-app-waf-01 \
  --filter-pattern "block"
```

### S3 Logging

More cost-effective for long-term retention:

```hcl
enable_logging       = true
log_destination_type = "s3"
s3_bucket_arn        = aws_s3_bucket.waf_logs.arn
```

**S3 bucket requirements:**
- Bucket must have prefix: `aws-waf-logs-`
- Example: `aws-waf-logs-myorg-prod`

### Kinesis Data Firehose

For real-time analysis or streaming to other systems:

```hcl
enable_logging       = true
log_destination_type = "kinesis"
kinesis_firehose_arn = aws_kinesis_firehose_delivery_stream.waf.arn
```

### Redacting Sensitive Data

Remove sensitive data from logs for privacy/compliance:

```hcl
redacted_fields = [
  {
    single_header = "authorization"  # Remove auth tokens
  },
  {
    single_header = "cookie"  # Remove cookies
  },
  {
    query_string = true  # Remove entire query string
  },
  {
    uri_path = true  # Remove URI path
  },
  {
    method = true  # Remove HTTP method
  }
]
```

## CloudWatch Metrics

WAF automatically publishes metrics to CloudWatch:

**Key metrics:**
- `AllowedRequests` - Requests that matched allow rules
- `BlockedRequests` - Requests that were blocked
- `CountedRequests` - Requests in count mode (for testing)
- `PassedRequests` - Requests that didn't match any rules

**View metrics:**
```bash
# Web ACL metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/WAFV2 \
  --metric-name BlockedRequests \
  --dimensions Name=WebACL,Value=myorg-prod-app-waf-01 Name=Region,Value=us-east-1 Name=Rule,Value=ALL \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

**Create CloudWatch Alarms:**
```hcl
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "waf-high-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "Alert when blocked requests exceed 1000 in 5 minutes"

  dimensions = {
    WebACL = module.waf.web_acl_name
    Region = data.aws_region.current.name
    Rule   = "ALL"
  }
}
```

## Monitoring and Troubleshooting

### View Sampled Requests

See actual requests that were blocked:

```bash
# Using Terraform output
terraform output waf_get_sampled_requests_command

# View last 100 blocked requests
aws wafv2 get-sampled-requests \
  --web-acl-arn <web-acl-arn> \
  --rule-metric-name <metric-name> \
  --scope REGIONAL \
  --time-window StartTime=$(date -u -d '1 hour ago' +%s),EndTime=$(date -u +%s) \
  --max-items 100
```

### List Associated Resources

```bash
terraform output waf_list_resources_command

# Or directly
aws wafv2 list-resources-for-web-acl \
  --web-acl-arn <web-acl-arn> \
  --resource-type APPLICATION_LOAD_BALANCER
```

### Testing Rules

**Use count mode** to test rules without blocking:

```hcl
# Set rate limit to count mode for testing
rate_limit_action = "count"

# Check CloudWatch metrics to see how many requests would be blocked
# Then switch to "block" when ready
```

### False Positives

If legitimate requests are being blocked:

1. **Check sampled requests** to identify which rule is blocking
2. **Review CloudWatch metrics** per rule
3. **Disable specific rules** if causing issues:
   ```hcl
   enable_sql_injection = false  # Temporarily disable
   ```
4. **Adjust rule priorities** if needed
5. **Add IPs to allowlist** for trusted sources

## Rule Priorities

Lower number = higher priority (runs first):

```
1-5:    IP Allowlist (custom)
6:      IP Blocklist (custom)
7:      Rate Limiting (custom)
8:      Geographic Blocking (custom)
10:     Core Rule Set (AWS Managed)
20:     Known Bad Inputs (AWS Managed)
30:     SQL Injection (AWS Managed)
40-60:  OS-specific (AWS Managed)
70-80:  App-specific (AWS Managed)
90:     IP Reputation (AWS Managed)
100:    Anonymous IP List (AWS Managed)
110:    Bot Control (AWS Managed)
```

**Customize priorities:**
```hcl
ip_allowlist_priority    = 5
core_rule_set_priority   = 10
rate_limit_priority      = 15  # Move before Core Rule Set
```

## Cost Optimization

**AWS WAF Pricing (as of 2024):**
- Web ACL: $5/month
- Rules: $1/month per rule
- Requests: $0.60 per million requests

**Cost Examples:**

**Basic Protection** (Core + Known Bad Inputs + IP Reputation):
- Web ACL: $5/month
- 3 Managed Rules: $3/month
- 10M requests: $6/month
- **Total: ~$14/month**

**Standard Protection** (+SQL Injection + Rate Limiting):
- Web ACL: $5/month
- 4 Managed Rules + 1 Custom: $5/month
- 50M requests: $30/month
- **Total: ~$40/month**

**Maximum Protection** (All rules + Bot Control):
- Web ACL: $5/month
- 10+ Rules: $10+/month
- Bot Control: $10/month + $1/million requests
- 100M requests: $60/month + $100 for bots
- **Total: ~$185/month**

**Tips:**
- Start with Core Rule Set + Known Bad Inputs
- Add more rules as needed
- Use count mode first to avoid blocking legitimate traffic
- Bot Control is expensive - only enable if needed
- Use S3 logging for long-term retention (cheaper than CloudWatch)

## Security Best Practices

1. **Enable Core Protection First**
   ```hcl
   enable_core_rule_set    = true
   enable_known_bad_inputs = true
   enable_sql_injection    = true
   ```

2. **Use Rate Limiting**
   ```hcl
   enable_rate_limiting = true
   rate_limit           = 2000  # Adjust based on traffic
   ```

3. **Enable Logging**
   ```hcl
   enable_logging = true
   ```

4. **Start with Count Mode**
   ```hcl
   # Test rules first
   rate_limit_action = "count"
   # Monitor for false positives, then switch to block
   ```

5. **Redact Sensitive Data**
   ```hcl
   redacted_fields = [
     { single_header = "authorization" },
     { single_header = "cookie" }
   ]
   ```

6. **Monitor Metrics**
   - Set up CloudWatch alarms for blocked requests
   - Review sampled requests regularly

7. **Regular Updates**
   - AWS Managed Rules are automatically updated
   - Review and update custom rules quarterly

## Outputs

| Output | Description |
|--------|-------------|
| `web_acl_id` | WAF Web ACL ID |
| `web_acl_arn` | WAF Web ACL ARN |
| `web_acl_name` | WAF Web ACL name |
| `web_acl_capacity` | Capacity units used |
| `log_group_name` | CloudWatch log group name |
| `enabled_managed_rule_groups` | List of enabled managed rules |
| `rate_limiting_enabled` | Whether rate limiting is enabled |
| `geo_blocking_enabled` | Whether geo blocking is enabled |
| `view_logs_command` | Command to view WAF logs |
| `get_sampled_requests_command` | Command to get sampled requests |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Limitations

- CloudFront WAF must be created in us-east-1 region
- S3 bucket names for logging must start with `aws-waf-logs-`
- Maximum 1500 WCUs (Web ACL Capacity Units) per Web ACL
- Rate limit is per 5-minute period (not configurable)
- Bot Control requires additional charges

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## References

- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)
- [AWS Managed Rules](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups.html)
- [WAF Pricing](https://aws.amazon.com/waf/pricing/)
- [WAF Best Practices](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-best-practices.html)
