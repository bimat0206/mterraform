# AWS Config Terraform Module

This module deploys AWS Config with organization-level aggregation, managed rules, and compliance monitoring.

## Features

- **Configuration Recorder**: Records resource configurations and changes
- **Delivery Channel**: Stores configuration snapshots in S3 with lifecycle policies
- **Organization Aggregator**: Aggregates Config data across all accounts and regions
- **Managed Rules**: Supports AWS managed Config rules for compliance
- **SNS Notifications**: Alerts for configuration changes and compliance violations
- **IAM Role**: Automatically creates IAM role with proper permissions
- **Security**: Encrypted S3 bucket with versioning and public access block

## Usage

```hcl
module "config" {
  source = "../modules/config"

  # Naming
  org_prefix  = "myorg"
  environment = "management"
  workload    = "org"

  # Config Settings
  enable_config                   = true
  include_global_resource_types   = true
  recording_frequency             = "CONTINUOUS"

  # Organization Aggregator
  enable_organization_aggregator = true
  aggregator_regions             = []  # Empty = all regions

  # S3 Bucket
  create_s3_bucket           = true
  s3_bucket_lifecycle_days   = 2555  # 7 years

  # SNS Notifications
  create_sns_topic         = true
  sns_email_subscriptions  = ["security@example.com"]

  # Managed Rules
  enable_managed_rules = true
  managed_rules = {
    encrypted-volumes = {
      description = "Ensure EBS volumes are encrypted"
      identifier  = "ENCRYPTED_VOLUMES"
    }
    iam-password-policy = {
      description = "Ensure IAM password policy meets requirements"
      identifier  = "IAM_PASSWORD_POLICY"
      input_parameters = {
        RequireUppercaseCharacters = "true"
        RequireLowercaseCharacters = "true"
        RequireNumbers             = "true"
        MinimumPasswordLength      = "14"
      }
    }
  }

  tags = {
    Project = "LandingZone"
  }
}
```

## Common Managed Rules

Here are some commonly used AWS managed Config rules:

### Security Rules
- `ENCRYPTED_VOLUMES` - Check if EBS volumes are encrypted
- `S3_BUCKET_PUBLIC_READ_PROHIBITED` - Check if S3 buckets prohibit public read
- `S3_BUCKET_PUBLIC_WRITE_PROHIBITED` - Check if S3 buckets prohibit public write
- `IAM_PASSWORD_POLICY` - Check if IAM password policy meets requirements
- `ROOT_ACCOUNT_MFA_ENABLED` - Check if root account has MFA enabled
- `IAM_USER_MFA_ENABLED` - Check if IAM users have MFA enabled

### Compliance Rules
- `REQUIRED_TAGS` - Check if resources have required tags
- `APPROVED_AMIS_BY_ID` - Check if EC2 instances use approved AMIs
- `RDS_STORAGE_ENCRYPTED` - Check if RDS instances are encrypted
- `CLOUDTRAIL_ENABLED` - Check if CloudTrail is enabled

See full list: https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html

## Requirements

- Terraform >= 1.6.0
- AWS Provider >= 5.0
- AWS Organizations enabled
- Config enabled in the management account

## Inputs

See [variables.tf](variables.tf) for all available inputs.

## Outputs

See [outputs.tf](outputs.tf) for all available outputs.

## Notes

- Set `include_global_resource_types = true` in only ONE region (typically us-east-1)
- Config rules are evaluated after the configuration recorder is enabled
- Email subscriptions require manual confirmation via email
- S3 lifecycle policy retains data for 7 years by default (compliance requirement)
- Organization aggregator requires AWS Organizations to be enabled
