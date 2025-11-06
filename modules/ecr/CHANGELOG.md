# Changelog

All notable changes to the ECR module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of ECR module with comprehensive features
- Multiple ECR repository support with per-repository configuration
- Automatic lifecycle policies for image cleanup:
  - Protected tags (never expire specific tags like `latest`, `prod`)
  - Tagged image expiry based on age (default: 90 days)
  - Image count limits (default: 30 most recent images)
  - Untagged image expiry (default: 7 days)
- Image scanning support:
  - Basic scanning with Clair (free, scan on push)
  - Enhanced scanning with AWS Inspector (additional cost, continuous or on-push)
- Encryption options:
  - AES256 (default, AWS-managed keys)
  - KMS (customer-managed keys)
- Image tag mutability control:
  - MUTABLE: Tags can be overwritten (default)
  - IMMUTABLE: Tags cannot be overwritten (recommended for production)
- Cross-region and cross-account replication:
  - Multiple destination regions
  - Repository filters for selective replication
  - Support for same-account and cross-account replication
- Pull through cache support:
  - Cache images from Docker Hub, GitHub Container Registry, Quay.io, etc.
  - Reduce rate limiting from public registries
  - Improve availability and reduce latency
  - Support for authenticated and unauthenticated registries
- Repository policies for fine-grained access control
- Force delete option for repositories
- Per-repository custom tags

### File Organization
- **versions.tf**: Provider requirements (Terraform >= 1.6.0, AWS ~> 5.0)
- **variables.tf**: 15+ input variables for comprehensive configuration
- **data.tf**: Data sources and local values for naming
- **repositories.tf**: ECR resources (repositories, lifecycle policies, scanning, replication, pull-through cache)
- **outputs.tf**: 15+ outputs including repository URLs, Docker commands, and summary
- **README.md**: Comprehensive documentation with examples
- **CHANGELOG.md**: This file

### Outputs
- Repository information (ARNs, URLs, names, registry IDs)
- Registry information (ID, URL)
- Enhanced scanning status
- Replication configuration
- Pull through cache rules
- Docker authentication command
- Per-repository Docker commands (build, tag, push, pull)
- Repository count
- Configuration summary

### Features Summary
- **Multi-Repository**: Manage multiple ECR repositories with different configurations
- **Automatic Cleanup**: Lifecycle policies prevent unbounded storage growth
- **Security**: Image scanning, encryption, and repository policies
- **High Availability**: Cross-region replication for disaster recovery
- **Cost Optimization**: Pull through cache reduces data transfer costs
- **Developer Friendly**: Outputs include Docker commands for easy usage
- **Production Ready**: IMMUTABLE tags, protected tags, and force delete prevention

### Default Values
- Image tag mutability: `MUTABLE`
- Scan on push: `true`
- Encryption type: `AES256`
- Max image count: `30`
- Max untagged days: `7`
- Max tagged days: `90`
- Protected tags: `["latest", "prod", "production"]`
- Enable untagged expiry: `true`
- Enhanced scanning: `false`
- Scan frequency: `SCAN_ON_PUSH`
- Replication: `false`
- Pull through cache: `false`
- Force delete: `false`

### Lifecycle Policy Rules
1. **Protected Tags** (Priority 1): Keep images with protected tags indefinitely
2. **Tagged Image Expiry** (Priority 2): Remove tagged images older than max_tagged_days
3. **Image Count Limit** (Priority 3): Keep only max_image_count most recent images
4. **Untagged Image Expiry** (Priority 4): Remove untagged images older than max_untagged_days

### Image Scanning
- **Basic Scanning**: Free, scans on push, identifies CVEs using Clair
- **Enhanced Scanning**: Additional cost (~$0.09 per scan), AWS Inspector, continuous monitoring

### Replication Use Cases
- Disaster recovery across regions
- Multi-region application deployments
- Cross-account image sharing
- Reduced latency in different geographic regions

### Pull Through Cache Benefits
- Faster image pulls (cached in your region)
- Reduced rate limiting from public registries (e.g., Docker Hub)
- Improved availability (local cache)
- Cost savings on data transfer

### Repository Naming
- Format: `{org_prefix}-{environment}-{workload}-{repository_key}`
- Example: `myorg-prod-api-backend`

### Cost Considerations
- Storage: $0.10 per GB per month
- Data transfer: Standard AWS rates
- Enhanced scanning: ~$0.09 per image scan (first scan free per repository)
- Replication: Data transfer costs between regions
- Pull through cache: Storage and data transfer costs

### Best Practices Implemented
- Automatic lifecycle policies prevent unbounded storage costs
- Scan on push enabled by default for security
- Protected tags prevent accidental deletion of production images
- Per-repository configuration for flexibility
- Comprehensive outputs for easy integration

### Notes
- Lifecycle policies run once per day (AWS-managed schedule)
- Enhanced scanning requires AWS Inspector service
- Pull through cache requires Secrets Manager for authenticated registries
- Replication is eventually consistent (typically seconds to minutes)
- Image tag mutability cannot be changed after repository creation (requires recreation)
- Force delete should be used cautiously (can lead to data loss)

### Known Limitations
- Maximum 10,000 images per repository
- Maximum 1,000 repositories per region per account (can be increased)
- Lifecycle policies evaluated once per day (not immediate)
- Pull through cache does not support all public registries
- Enhanced scanning not available in all regions

## [Unreleased]

### Planned
- Registry policy support for registry-wide access control
- Public repository support (ECR Public)
- Image signing and verification
- Integration with AWS Signer
- Automated vulnerability remediation workflows
- Cost allocation tags for chargeback
