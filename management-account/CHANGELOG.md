# Changelog

All notable changes to the management-account configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of management account Terraform configuration
- Directory structure for management account resources
- Terraform configuration files:
  - versions.tf: Terraform and AWS provider version constraints
  - providers.tf: AWS provider with default tags
  - backend.tf: Remote state backend configuration
  - backend.hcl.example: S3 backend configuration example
  - locals.tf: Local values and common tags
  - variables.tf: Input variable definitions
  - main.tf: Module calls
  - outputs.tf: Output values
  - terraform.tfvars.example: Comprehensive configuration examples
  - dev.tfvars: Development environment configuration
  - prod.tfvars: Production environment configuration
  - README.md: Complete documentation
  - CHANGELOG.md: Version history

### IAM Identity Center Integration
- Module integration for IAM Identity Center (AWS SSO)
- Support for Identity Store users and groups
- Support for external identity providers (Azure AD, Okta, etc.)
- Permission set management
- Account assignment management
- Comprehensive outputs for Identity Center resources

### Configuration Options
- General configuration (region, organization prefix, environment, workload)
- Identity Center enablement toggle
- Identity Store user/group creation flags
- Permission set definitions with:
  - AWS managed policies
  - Customer managed policies
  - Inline policies
  - Permissions boundaries
  - Session durations
- Account assignment configurations
- External IdP support
- Tag management

### Documentation
- Comprehensive README with:
  - Overview and prerequisites
  - Quick start guide
  - IAM Identity Center configuration examples
  - Internal Identity Store setup
  - External IdP integration
  - Common permission set examples
  - Multi-account access patterns
  - User access instructions (Console and CLI)
  - Session duration guidelines
  - Best practices
  - Troubleshooting guide
  - Security considerations
- Example configurations in terraform.tfvars.example:
  - Internal Identity Store with users/groups
  - External Identity Provider (Azure AD)
  - Minimal setup example
  - Common permission sets
  - Multi-account assignments
  - Session duration guidelines
  - AWS CLI configuration instructions

### Features Summary
- **Management Account Specific**: Designed for AWS Organizations management account
- **IAM Identity Center**: Centralized SSO and access management
- **Multi-Account**: Support for organization-wide access
- **Flexible**: Internal or external identity providers
- **Production Ready**: Best practices and comprehensive examples
- **Well Documented**: Extensive README and examples

### File Organization
All configuration files organized in a clear structure:
- Terraform configuration files
- Environment-specific tfvars
- Backend configuration example
- Comprehensive documentation

### Use Cases
- Centralized access management for AWS Organization
- Single sign-on to multiple AWS accounts
- Integration with corporate identity providers
- Role-based access control across accounts
- Temporary elevated access with session durations
- Audit and compliance tracking

### Best Practices Implemented
- Group-based access control
- Least privilege principle
- Appropriate session durations
- Remote state backend support
- Environment-specific configurations
- Comprehensive tagging strategy
- Modular design

### Default Values
- AWS region: us-east-1
- Environment: management
- Workload: org
- Identity Center: disabled by default
- Identity Store users/groups: not created by default
- External IdP: disabled by default

### Prerequisites Documentation
- AWS Organizations requirement
- IAM Identity Center enablement
- Administrator access requirement
- Terraform version requirement
- Identity provider setup (if using external IdP)

### Security Features
- MFA support (configured in Console or IdP)
- Permissions boundaries
- Session duration controls
- Audit logging via CloudTrail
- Least privilege access patterns
- Tag-based access control

### Integration
- AWS Organizations
- IAM Identity Center module
- External identity providers (Azure AD, Okta, etc.)
- AWS CLI SSO
- SDK integration

### Known Limitations
- IAM Identity Center must be enabled in Console first
- Single instance per organization
- Permission changes take 5-10 minutes to propagate
- External groups/users must exist before referencing
- Maximum 50 permission sets per instance (default)
- Maximum 10 AWS managed policies per permission set
- Maximum 20 customer managed policies per permission set
- Session duration maximum: PT12H (12 hours)

### Cost
- IAM Identity Center: FREE
- No charges for users, groups, permission sets, or assignments
- External IdP may have separate costs
- Only pay for AWS resources accessed by users

## [Unreleased]

### Planned
- AWS Organizations configuration module
- Organization-wide CloudTrail
- Organization-wide AWS Config
- SCPs (Service Control Policies) management
- Organizational units management
- Account creation automation
- Backup policies
- Tag policies
- AI services opt-out policies
- Additional IAM Identity Center features
