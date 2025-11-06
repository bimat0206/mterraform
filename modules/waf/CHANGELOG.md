# Changelog

All notable changes to the WAF module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of AWS WAFv2 module with comprehensive protection
- Web ACL with configurable default action (allow/block)
- Scope support for REGIONAL and CLOUDFRONT

### AWS Managed Rule Groups (Toggle On/Off)
- **Core Rule Set**: OWASP Top 10 protection (enabled by default)
- **Known Bad Inputs**: Known malicious patterns (enabled by default)
- **SQL Injection**: Advanced SQL injection protection (enabled by default)
- **Linux OS**: Linux-specific attack protection
- **Unix OS**: Unix-specific attack protection
- **Windows OS**: Windows-specific attack protection
- **PHP Application**: PHP vulnerability protection
- **WordPress Application**: WordPress-specific protection
- **Amazon IP Reputation**: IP reputation blocking (enabled by default)
- **Anonymous IP List**: VPN/proxy/Tor blocking
- **Bot Control**: Advanced bot detection (additional charges)

### Custom Rules
- **IP Allowlist**: Always allow specific IP addresses or CIDR blocks
- **IP Blocklist**: Block specific IP addresses or CIDR blocks
- **Rate Limiting**: Configurable rate limit per IP (requests per 5 minutes)
  - Action: block or count
  - Default: 2000 requests per 5 minutes
- **Geographic Blocking**: Block specific countries by ISO 3166-1 alpha-2 codes
- **Rule Priorities**: Configurable priority for all rules

### Resource Associations
- Application Load Balancer (ALB) association support
- API Gateway REST API stage association support
- AppSync GraphQL API association support
- CloudFront distribution support (via CloudFront configuration)
- Multiple resource associations per Web ACL

### Logging
- CloudWatch Logs integration (default)
  - Automatic log group creation
  - Configurable retention (1-3653 days, default: 7 days)
  - CloudWatch Log Resource Policy for WAF service
- S3 bucket logging support
- Kinesis Data Firehose logging support
- Redacted fields for privacy/compliance:
  - HTTP method
  - Query string
  - URI path
  - Individual headers (e.g., authorization, cookie)

### CloudWatch Metrics
- Automatic metric publishing to CloudWatch
- Per-rule metrics (AllowedRequests, BlockedRequests, CountedRequests)
- Web ACL-level metrics
- Configurable metric name prefix
- Sampled requests enabled for troubleshooting

### File Organization
- **data.tf**: Data sources, locals, managed rule configurations
- **waf.tf**: Web ACL with all rule definitions
- **custom_rules.tf**: IP sets for allowlist/blocklist
- **logging.tf**: CloudWatch Logs and logging configuration
- **associations.tf**: Resource associations (ALB, API Gateway, AppSync)
- **versions.tf**: Provider requirements
- **variables.tf**: Input variables (100+ options)
- **outputs.tf**: Output values and management commands

### Outputs
- Web ACL information (ID, ARN, name, capacity)
- IP set ARNs (allowlist, blocklist)
- CloudWatch log group details
- Association counts per resource type
- Enabled managed rule groups list
- Configuration summary (rate limiting, geo blocking, default action)
- Management commands:
  - View logs command
  - Get sampled requests command
  - List associated resources command
  - Describe Web ACL command
- CloudWatch metrics information (namespace, metric names)

### Configuration Options
- **100+ variables** for granular control
- Individual toggles for each AWS Managed Rule Group
- Configurable priorities for all rules
- Flexible logging destinations
- Multiple resource association types
- Custom IP management
- Rate limiting with configurable thresholds
- Geographic blocking with country code support

### Default Values
- Scope: `REGIONAL`
- Default action: `allow`
- AWS Managed Rules: Enabled
- Core Rule Set: Enabled
- Known Bad Inputs: Enabled
- SQL Injection: Enabled
- Amazon IP Reputation: Enabled
- CloudWatch metrics: Enabled
- Logging: Enabled (CloudWatch Logs)
- Log retention: 7 days

### Features Summary
- **Toggle AWS Managed Rules**: Enable/disable 11 different rule groups
- **Custom Rules**: IP management, rate limiting, geo blocking
- **Resource Associations**: Support for ALB, API Gateway, AppSync, CloudFront
- **Comprehensive Logging**: CloudWatch, S3, or Kinesis options
- **Production Ready**: Best practices, metrics, monitoring
- **Cost Optimized**: Enable only needed rules
- **Flexible**: 100+ configuration variables
- **Organized**: Modular file structure for easier troubleshooting
- **Secure**: Privacy-aware logging with field redaction

### Security Features
- OWASP Top 10 protection via Core Rule Set
- SQL injection prevention
- XSS (Cross-Site Scripting) protection
- LFI/RFI (File Inclusion) protection
- RCE (Remote Code Execution) prevention
- Known malicious pattern blocking
- IP reputation-based blocking
- DDoS protection via rate limiting
- Geographic access control
- Bot detection and mitigation
- OS-specific attack protection
- Application-specific vulnerability protection

### Use Cases
- Public-facing web applications
- REST APIs and GraphQL APIs
- WordPress and PHP applications
- Applications with database backends
- Content delivery via CloudFront
- Rate-limited APIs
- Geographic-restricted services
- Bot-protected applications

### CloudWatch Integration
- Automatic metric publishing
- Real-time monitoring
- Alert-ready metrics
- Per-rule visibility
- Sampled request capture
- CloudWatch Insights compatibility

### Compliance and Privacy
- Field redaction support
- Audit logging
- Configurable log retention
- PCI-DSS compatible
- GDPR-ready with redaction

### Cost Considerations
- Web ACL: $5/month
- Rules: $1/month per rule
- Requests: $0.60 per million
- Bot Control: $10/month + $1/million requests (optional)
- CloudWatch Logs: $0.50/GB ingested (if enabled)
- S3 storage: Lower cost for long-term retention

### Known Limitations
- CloudFront WAF must be created in us-east-1 region
- S3 bucket names must start with `aws-waf-logs-`
- Maximum 1500 WCUs per Web ACL
- Rate limit is per 5-minute period (not configurable)
- Bot Control requires additional charges
- CloudFront associations handled in CloudFront resource (not via association resource)

### Migration Notes
- Migrating from WAFv1 (Classic) requires recreation
- No in-place upgrade path from WAFv1 to WAFv2
- Test rules in count mode before enabling block mode

### Best Practices Implemented
- IP allowlist has highest priority
- Core protection enabled by default
- CloudWatch metrics enabled for monitoring
- Logging enabled by default
- Sensible default priorities
- Field redaction support for compliance
- Organized file structure for maintainability

## [Unreleased]

### Planned
- Regex pattern set support
- Custom request/response headers
- Challenge action support (CAPTCHA)
- AWS Shield Advanced integration
- Terraform count/for_each examples
- Advanced Bot Control configurations
- Rule group versioning
- Automated rule testing framework
