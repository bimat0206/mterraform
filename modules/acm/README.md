# ACM Module

Creates an AWS ACM (Certificate Manager) certificate with DNS validation via Route53.

## Features

- ACM certificate with DNS validation
- Support for Subject Alternative Names (SANs)
- Automatic Route53 DNS validation records
- Automatic validation completion
- Consistent naming and tagging

## Usage

```hcl
module "acm" {
  source = "../modules/acm"

  # Naming inputs
  org_prefix  = "tsk"
  environment = "dev"
  workload    = "app"
  service     = "acm"
  identifier  = "01"

  # ACM configuration
  domain_name               = "example.com"
  subject_alternative_names = ["*.example.com", "www.example.com"]
  hosted_zone_id            = "Z1234567890ABC"
  validation_ttl            = 60

  # Tags
  tags = {
    owner       = "cloud-platform"
    cost-center = "CC-1234"
    project     = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| org_prefix | Organization prefix for resource naming | string | - | yes |
| environment | Environment name (dev, prod, staging) | string | - | yes |
| workload | Workload name | string | - | yes |
| service | Service name override | string | null | no |
| identifier | Unique identifier | string | null | no |
| tags | Additional tags | map(string) | {} | no |
| domain_name | Primary domain name for the certificate | string | - | yes |
| subject_alternative_names | SANs for the certificate | list(string) | [] | no |
| hosted_zone_id | Route53 hosted zone ID for DNS validation | string | - | yes |
| validation_ttl | TTL for DNS validation records | number | 60 | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arn | The ARN of the certificate |
| certificate_id | The ID of the certificate |
| certificate_name | The name of the certificate |
| certificate_domain_name | The domain name of the certificate |
| certificate_status | The status of the certificate |
| certificate_validation_status | The validation status of the certificate |
| domain_validation_options | Domain validation options for the certificate |

## Resource Naming

Resources are named using the pattern: `{org_prefix}-{environment}-{workload}-{service}-{identifier}`

Example: `tsk-dev-app-acm-01`

## Notes

- The certificate uses DNS validation via Route53
- DNS validation records are automatically created in the specified hosted zone
- The module waits for validation to complete before marking resources as created
- The certificate has `create_before_destroy` lifecycle policy for safe updates
