# AWS GuardDuty Terraform Module

This module deploys AWS GuardDuty with organization-level threat detection, multiple protection features, and automated notifications.

## Features

- **GuardDuty Detector**: Continuous threat detection and monitoring
- **Organization Integration**: Auto-enable for all member accounts
- **Multi-Layer Protection**:
  - S3 Protection (monitors S3 data events)
  - EKS Protection (monitors Kubernetes audit logs and runtime)
  - Malware Protection (scans EBS volumes)
  - RDS Protection (monitors login activity)
  - Lambda Protection (monitors network activity)
- **Findings Export**: Automated export to S3 bucket
- **Real-time Notifications**: CloudWatch Events + SNS for immediate alerts
- **Severity Filtering**: Configurable threshold for notifications

## Usage

```hcl
module "guardduty" {
  source = "../modules/guardduty"

  # Naming
  org_prefix  = "myorg"
  environment = "management"
  workload    = "security"

  # GuardDuty Configuration
  enable_guardduty              = true
  finding_publishing_frequency  = "FIFTEEN_MINUTES"

  # Protection Features
  enable_s3_protection         = true
  enable_eks_protection        = true
  enable_malware_protection    = true
  enable_rds_protection        = true
  enable_lambda_protection     = true

  # Organization Configuration
  enable_organization_admin_account = true
  auto_enable_organization_members  = true

  # Findings Export
  enable_s3_export = true

  # Notifications (only medium and high severity findings)
  enable_sns_notifications = true
  sns_email_subscriptions  = ["security@example.com"]
  finding_severity_filter  = [4, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5, 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9]

  tags = {
    Project = "LandingZone"
  }
}
```

## GuardDuty Severity Levels

- **Low (1-3.9)**: Informational findings, usually benign
- **Medium (4-6.9)**: Suspicious activity that warrants investigation
- **High (7-8.9)**: Serious threats requiring immediate action

## Protection Features

### S3 Protection
Monitors S3 data events to detect:
- Unusual API calls
- Data exfiltration attempts
- Unauthorized access
- Suspicious bucket policy changes

### EKS Protection
Monitors Kubernetes audit logs and runtime activity:
- Kubernetes API calls
- Unauthorized kubectl commands
- Container runtime anomalies
- Pod security issues

### Malware Protection
Scans EBS volumes attached to EC2 instances:
- Triggered when GuardDuty detects suspicious activity
- Agentless scanning
- Detects malware, trojans, and coin miners

### RDS Protection
Monitors RDS login activity:
- Brute force attacks
- Suspicious login patterns
- Anomalous database access

### Lambda Protection
Monitors Lambda network activity:
- Unusual outbound connections
- Command and control traffic
- Cryptocurrency mining

## Requirements

- Terraform >= 1.6.0
- AWS Provider >= 5.0
- AWS Organizations enabled (for organization features)

## Inputs

See [variables.tf](variables.tf) for all available inputs.

## Outputs

See [outputs.tf](outputs.tf) for all available outputs.

## Notes

- GuardDuty has no upfront costs, pay only for events analyzed
- Protection features have additional costs (check AWS pricing)
- Email subscriptions require manual confirmation
- Organization admin must be enabled from the management account
- Findings are retained for 90 days in the GuardDuty console
