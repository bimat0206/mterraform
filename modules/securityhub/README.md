# AWS Security Hub Terraform Module

This module deploys AWS Security Hub with organization-level security posture management, multiple compliance standards, and automated product integrations.

## Features

- **Security Hub Account**: Centralized security findings and compliance
- **Organization Integration**: Auto-enable for all member accounts
- **Security Standards**:
  - CIS AWS Foundations Benchmark
  - AWS Foundational Security Best Practices
  - PCI DSS (optional)
  - NIST SP 800-53 Rev. 5 (optional)
- **Product Integrations**: Automatic integration with GuardDuty, Config, Inspector, IAM Access Analyzer, Macie, Firewall Manager
- **Finding Aggregator**: Cross-region aggregation of security findings
- **Real-time Notifications**: CloudWatch Events + SNS for immediate alerts
- **Severity Filtering**: Configurable threshold for notifications

## Usage

```hcl
module "securityhub" {
  source = "../modules/securityhub"

  # Naming
  org_prefix  = "myorg"
  environment = "management"
  workload    = "security"

  # Security Hub Configuration
  enable_security_hub           = true
  enable_default_standards      = true
  control_finding_generator     = "SECURITY_CONTROL"

  # Organization Configuration
  enable_organization_admin_account = true
  auto_enable_organization_members  = true
  auto_enable_default_standards     = true

  # Security Standards
  enable_cis_standard            = true
  cis_standard_version           = "1.4.0"
  enable_aws_foundational_standard = true
  enable_pci_dss_standard        = false
  enable_nist_standard           = false

  # Product Integrations
  enable_product_integrations = true  # Auto-detects available products

  # Finding Aggregator
  enable_finding_aggregator   = true
  aggregator_linking_mode     = "ALL_REGIONS"

  # Notifications (critical, high, and medium findings)
  enable_sns_notifications = true
  sns_email_subscriptions  = ["security@example.com"]
  finding_severity_filter  = ["CRITICAL", "HIGH", "MEDIUM"]
  workflow_status_filter   = ["NEW", "NOTIFIED"]

  tags = {
    Project = "LandingZone"
  }
}
```

## Security Standards

### CIS AWS Foundations Benchmark
- Industry-recognized security best practices
- Comprehensive coverage of AWS services
- Available versions: 1.2.0, 1.4.0 (recommended)

### AWS Foundational Security Best Practices (FSBP)
- AWS-authored security controls
- Best practices across all AWS services
- Continuously updated by AWS

### PCI DSS (Payment Card Industry Data Security Standard)
- Required for organizations handling credit card data
- Comprehensive security controls
- Version 3.2.1

### NIST SP 800-53 Rev. 5
- Federal government compliance standard
- Comprehensive security and privacy controls
- Suitable for highly regulated environments

## Finding Severity Levels

- **CRITICAL**: Immediate action required, potential data breach
- **HIGH**: Serious security issues, prompt attention needed
- **MEDIUM**: Notable security concerns, should be addressed
- **LOW**: Informational findings, best practice recommendations
- **INFORMATIONAL**: No security risk, awareness only

## Product Integrations

Security Hub automatically aggregates findings from:
- **AWS GuardDuty**: Threat detection
- **AWS Config**: Configuration compliance
- **Amazon Inspector**: Vulnerability management
- **IAM Access Analyzer**: External resource access
- **Amazon Macie**: Sensitive data discovery
- **AWS Firewall Manager**: Firewall rule management

## Requirements

- Terraform >= 1.6.0
- AWS Provider >= 5.0
- AWS Organizations enabled (for organization features)
- Source services enabled (GuardDuty, Config, etc.)

## Inputs

See [variables.tf](variables.tf) for all available inputs.

## Outputs

See [outputs.tf](outputs.tf) for all available outputs.

## Notes

- Security Hub has a free 30-day trial, then pay per finding ingested and check
- Standards must be enabled individually in each region
- Email subscriptions require manual confirmation
- Organization admin must be enabled from the management account
- Finding aggregator consolidates findings from all regions
- Product subscriptions automatically enable when products are activated
