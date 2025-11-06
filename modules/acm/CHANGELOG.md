# Changelog - ACM Module

All notable changes to the ACM (AWS Certificate Manager) module will be documented in this file.

## [1.0.0] - 2025-11-06

### Added
- Initial release of ACM module
- ACM certificate creation with DNS validation
- Subject Alternative Names (SANs) support
- Automatic Route53 DNS validation record creation
- Automatic validation completion
- Configurable validation TTL
- Dynamic naming based on organizational standards
- Comprehensive outputs (ARN, ID, domain name, status)
- `create_before_destroy` lifecycle for safe updates

### Features
- **DNS Validation**: Automatic validation via Route53
- **SANs Support**: Multiple domain names on single certificate
- **Auto-Validation**: Automatically waits for validation to complete
- **Zero Downtime Updates**: `create_before_destroy` lifecycle policy
- **Regional**: Certificates deployed to current AWS region
- **Free**: AWS ACM certificates are free (only pay for resources using them)

### Requirements
- Terraform >= 1.6.0
- AWS Provider ~> 5.0
- Route53 hosted zone for domain validation

### Example Usage

**Single Domain:**
```hcl
module "acm" {
  source = "../modules/acm"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"

  domain_name    = "example.com"
  hosted_zone_id = "Z1234567890ABC"

  tags = {}
}
```

**Wildcard Certificate:**
```hcl
module "acm_wildcard" {
  source = "../modules/acm"

  org_prefix  = "tsk"
  environment = "prod"
  workload    = "web"

  domain_name               = "example.com"
  subject_alternative_names = [
    "*.example.com",
    "www.example.com"
  ]
  hosted_zone_id = "Z1234567890ABC"

  tags = {}
}
```

### Use Cases
- HTTPS/TLS for Application Load Balancers
- CloudFront distributions
- API Gateway custom domains
- Elastic Beanstalk applications
- Any AWS service requiring SSL/TLS certificates

### Validation
- Uses DNS validation (recommended by AWS)
- Automatically creates Route53 validation records
- Waits for validation to complete before marking resource as created
- Validation records are automatically removed on destroy

### Best Practices
- Use wildcard certificates (*.example.com) for subdomains
- Create certificates in the same region as your resources
- For CloudFront, create certificates in us-east-1
- Add all necessary SANs upfront to avoid recreation
- Tag certificates for cost allocation and management

### Documentation
- Comprehensive README with usage examples
- DNS validation workflow explained
- Best practices for certificate management
- Integration examples with ALB, CloudFront
