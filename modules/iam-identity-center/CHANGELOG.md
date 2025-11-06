# Changelog

All notable changes to the IAM Identity Center module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-06

### Added
- Initial release of IAM Identity Center (AWS SSO) module
- Automatic discovery of IAM Identity Center instance
- Identity Store ID retrieval

### Permission Sets
- Create and manage permission sets with configurable names
- Session duration configuration (ISO 8601 format, up to PT12H)
- Relay state configuration for custom redirect URLs
- AWS Managed Policy attachments (unlimited policies per permission set)
- Customer Managed Policy attachments with path support
- Inline policy support with JSON policy documents
- Permissions boundary support (AWS managed or customer managed)
- Per-permission-set tags

### Identity Store
- Create and manage users in Identity Store:
  - User name, display name
  - Email address (primary work email)
  - First name and last name
- Create and manage groups in Identity Store:
  - Display name
  - Description
- Automatic group membership management:
  - Assign users to multiple groups
  - Maintain group membership relationships

### External Identity Provider Support
- Support for external IdP (Azure AD, Okta, Google Workspace, etc.)
- Data source lookup for external groups by display name
- Data source lookup for external users by user name
- Mixed mode support (some groups internal, some external)
- Configurable external IdP mode

### Account Assignments
- Assign users to AWS accounts with permission sets
- Assign groups to AWS accounts with permission sets
- Multi-account support (unlimited assignments)
- Automatic principal ID resolution (users and groups)
- Target type: AWS_ACCOUNT

### File Organization
- **data.tf**: Data sources, locals, Identity Center discovery
- **identity_store.tf**: Users, groups, group memberships, external lookups
- **permission_sets.tf**: Permission sets and policy attachments
- **account_assignments.tf**: Account assignments
- **versions.tf**: Provider requirements
- **variables.tf**: Input variables
- **outputs.tf**: Output values and management commands

### Outputs
- IAM Identity Center instance ARN
- Identity Store ID
- Permission set ARNs (map by name)
- Permission set IDs (map by name)
- Permission set names (list)
- Group IDs (all groups - internal + external)
- Internal group IDs (Identity Store groups)
- External group IDs (IdP groups)
- User IDs (all users - internal + external)
- Internal user IDs (Identity Store users)
- External user IDs (IdP users)
- Account assignments (detailed map)
- Account assignment count
- Permission set count
- Internal group count
- Internal user count
- External groups configured count
- External users configured count
- AWS CLI management commands

### Configuration Options
- Flexible permission set configuration
- Support for multiple policy types simultaneously
- Group-based access control (recommended)
- User-based access control (for exceptions)
- Configurable session durations per permission set
- Optional permissions boundaries
- Tag support for all resources

### Default Values
- Session duration: PT1H (1 hour)
- Create Identity Store users: false
- Create Identity Store groups: false
- External IdP enabled: false

### Features Summary
- **Identity Store**: Create users and groups internally
- **External IdP**: Support for Azure AD, Okta, Google Workspace, etc.
- **Permission Sets**: Flexible policy configuration (AWS managed, customer managed, inline)
- **Account Assignments**: Assign users/groups to accounts
- **Group Memberships**: Automatic user-to-group associations
- **Permissions Boundaries**: Limit maximum permissions
- **Multi-Account**: Support for AWS Organizations
- **Production Ready**: Best practices for enterprise deployments

### Use Cases
- Multi-account AWS Organizations access management
- Single sign-on (SSO) for AWS Console and CLI
- Integration with corporate identity providers
- Centralized permission management
- Audit and compliance (all access through IAM Identity Center)
- Temporary elevated access with session durations
- Least privilege access control

### Best Practices Implemented
- Group-based access control
- Separate permission sets for different roles
- Configurable session durations
- Support for permissions boundaries
- Modular file organization
- Comprehensive outputs for troubleshooting
- Tag support for cost allocation

### Security Features
- Permissions boundaries to prevent privilege escalation
- Session duration limits
- Centralized access management
- Audit trail through CloudTrail
- MFA support (configured in AWS Console)
- Conditional access (via external IdP)
- Just-in-time access through session durations

### Integration
- AWS Organizations required
- Must be deployed in management account
- Works with external identity providers
- CloudTrail integration for audit logging
- AWS CLI integration (aws sso login)
- SDK integration (boto3, AWS SDK)

### Supported Permission Types
1. **AWS Managed Policies**: Pre-built policies from AWS
   - AdministratorAccess
   - PowerUserAccess
   - ReadOnlyAccess
   - ViewOnlyAccess
   - Job function policies (Billing, DataScientist, NetworkAdministrator, etc.)
   - Service-specific policies

2. **Customer Managed Policies**: Policies created in IAM
   - Reference by name and path
   - Must exist in target account

3. **Inline Policies**: JSON policy documents
   - Embedded in permission set
   - Custom permissions

4. **Permissions Boundaries**: Maximum permission limit
   - AWS managed policy ARN
   - Customer managed policy reference

### Known Limitations
- IAM Identity Center must be enabled in AWS Console first
- Can only have one Identity Center instance per organization
- Permission set changes can take 5-10 minutes to propagate
- External groups/users must exist in IdP before referencing
- Maximum 50 permission sets per instance (can be increased via support)
- Maximum 10 AWS managed policies per permission set
- Maximum 20 customer managed policies per permission set
- Session duration maximum is PT12H (12 hours)
- Account assignments are eventual consistency (5-10 minutes)

### Prerequisites
- AWS Organizations enabled
- IAM Identity Center enabled in AWS Console
- Management account access
- For external IdP: SAML 2.0 configuration completed

### Migration Notes
- If migrating from manual configuration, import existing resources
- User/group IDs are stable and can be imported
- Permission set ARNs can be imported
- Account assignments can be imported

### Terraform State
- All resources are tracked in Terraform state
- Use remote state backend for team collaboration
- Sensitive data: None (user passwords managed by IdP)
- State locking recommended for concurrent operations

## [Unreleased]

### Planned
- Application assignments (beyond AWS accounts)
- Automated permission set versioning
- Permission set templates
- Account assignment bulk operations
- Integration with AWS Control Tower
- Custom SAML attributes mapping
- Automated user provisioning from IdP (SCIM)
- Permission set comparison and diff
- Access request workflow integration
- Time-bound access assignments
