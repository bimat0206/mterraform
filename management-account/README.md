# Management Account Terraform Configuration

This directory contains Terraform configuration for the AWS Management Account, which hosts organization-wide services like IAM Identity Center (AWS SSO).

## Overview

The management account is the root account in an AWS Organization and typically hosts:
- **IAM Identity Center**: Centralized single sign-on and access management
- **AWS Organizations**: Organization and account management
- **AWS CloudTrail**: Organization-wide audit logging (if configured)
- **AWS Config**: Organization-wide compliance monitoring (if configured)

## Directory Structure

```
management-account/
├── versions.tf              # Terraform and provider versions
├── providers.tf             # AWS provider configuration
├── backend.tf              # Remote state backend configuration
├── backend.hcl.example     # Backend configuration example
├── locals.tf               # Local values and common tags
├── variables.tf            # Input variable definitions
├── main.tf                 # Main module calls
├── outputs.tf              # Output values
├── terraform.tfvars.example # Configuration examples
├── dev.tfvars              # Development environment overrides
├── prod.tfvars             # Production environment overrides
└── README.md               # This file
```

## Prerequisites

1. **AWS Organizations Enabled**: The management account must have AWS Organizations enabled
2. **IAM Identity Center Enabled**: Enable IAM Identity Center in the AWS Console first
   - Go to: AWS Console → IAM Identity Center → Enable
   - Choose your region (typically us-east-1)
3. **Administrator Access**: You need administrative access to the management account
4. **Terraform >= 1.6.0**: Ensure you have Terraform 1.6.0 or later installed

## Quick Start

### 1. Configure Remote State Backend (Recommended)

```bash
# Copy and customize backend configuration
cp backend.hcl.example backend.hcl
nano backend.hcl

# Update with your S3 bucket details:
# - bucket: your-terraform-state-bucket
# - key: management-account/terraform.tfstate
# - region: us-east-1
# - dynamodb_table: terraform-state-lock
```

### 2. Configure Variables

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Minimum required configuration:

```hcl
aws_region  = "us-east-1"
org_prefix  = "myorg"
environment = "management"
workload    = "org"

identity_center_enabled = true

# ... add your configuration here ...
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init -backend-config=backend.hcl

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## IAM Identity Center Configuration

### Option 1: Internal Identity Store

Use IAM Identity Center's built-in identity store:

```hcl
identity_center_enabled = true
create_identity_store_users = true
create_identity_store_groups = true

identity_center_groups = {
  administrators = {
    display_name = "Administrators"
    description  = "Full administrative access"
  }
  developers = {
    display_name = "Developers"
    description  = "Developer access"
  }
}

identity_center_users = {
  john_admin = {
    user_name    = "john.admin"
    display_name = "John Admin"
    email        = "john.admin@example.com"
    first_name   = "John"
    last_name    = "Admin"
    group_memberships = ["administrators"]
  }
}

identity_center_permission_sets = {
  AdministratorAccess = {
    description      = "Full admin access"
    session_duration = "PT8H"
    aws_managed_policies = ["AdministratorAccess"]
  }
}

identity_center_account_assignments = {
  "admins-management" = {
    account_id       = "111111111111"
    permission_set   = "AdministratorAccess"
    principal_type   = "GROUP"
    principal_name   = "administrators"
  }
}
```

### Option 2: External Identity Provider

Use an external IdP like Azure AD or Okta:

```hcl
identity_center_enabled = true
external_idp_enabled = true
create_identity_store_users = false
create_identity_store_groups = false

external_groups = {
  administrators = {
    display_name = "AWS-Administrators"  # Must match IdP group name
  }
}

# ... permission sets and assignments ...
```

**Steps for External IdP:**

1. Enable external IdP in AWS Console:
   - IAM Identity Center → Settings → Identity source
   - Choose "External identity provider"
   - Upload IdP metadata

2. Configure SAML in your IdP (Azure AD, Okta, etc.)

3. Reference external groups in Terraform configuration

## Common Permission Sets

### Administrative Access

```hcl
AdministratorAccess = {
  description      = "Full administrative access"
  session_duration = "PT8H"
  aws_managed_policies = ["AdministratorAccess"]
}

PowerUserAccess = {
  description      = "Full access except IAM"
  session_duration = "PT4H"
  aws_managed_policies = ["PowerUserAccess"]
}
```

### Developer Access

```hcl
DeveloperAccess = {
  description      = "Developer with deployment permissions"
  session_duration = "PT8H"
  aws_managed_policies = ["PowerUserAccess"]
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Read-Only Access

```hcl
ReadOnlyAccess = {
  description      = "Read-only access"
  session_duration = "PT2H"
  aws_managed_policies = ["ReadOnlyAccess"]
}

ViewOnlyAccess = {
  description      = "Console view-only"
  session_duration = "PT2H"
  aws_managed_policies = ["job-function/ViewOnlyAccess"]
}
```

### Service-Specific Access

```hcl
BillingAccess = {
  description      = "Billing and cost management"
  session_duration = "PT4H"
  aws_managed_policies = ["job-function/Billing"]
}

DataScientistAccess = {
  description      = "Data science tools access"
  session_duration = "PT8H"
  aws_managed_policies = ["job-function/DataScientist"]
}

NetworkAdministratorAccess = {
  description      = "Network administration"
  session_duration = "PT8H"
  aws_managed_policies = ["job-function/NetworkAdministrator"]
}
```

## Multi-Account Access

Assign permissions across multiple accounts:

```hcl
identity_center_account_assignments = {
  # Management account
  "admins-management" = {
    account_id       = "111111111111"
    permission_set   = "AdministratorAccess"
    principal_type   = "GROUP"
    principal_name   = "administrators"
  }

  # Network account
  "admins-network" = {
    account_id       = "222222222222"
    permission_set   = "AdministratorAccess"
    principal_type   = "GROUP"
    principal_name   = "administrators"
  }

  # Development workload
  "devs-dev" = {
    account_id       = "333333333333"
    permission_set   = "DeveloperAccess"
    principal_type   = "GROUP"
    principal_name   = "developers"
  }

  # Production workload
  "readonly-prod" = {
    account_id       = "444444444444"
    permission_set   = "ReadOnlyAccess"
    principal_type   = "GROUP"
    principal_name   = "readonly"
  }
}
```

## User Access

After deployment, users can access AWS accounts:

### Web Console Access

1. Navigate to AWS SSO portal URL (shown in IAM Identity Center settings)
2. Log in with username/password (or IdP credentials)
3. Select account and permission set
4. Access AWS Console

### AWS CLI Access

Configure AWS CLI for SSO:

```bash
# Configure SSO profile
aws configure sso

# Prompts:
# SSO start URL: https://myorg.awsapps.com/start
# SSO region: us-east-1
# Account ID: 111111111111
# Role name: AdministratorAccess
# CLI default output format: json
# Profile name: management-admin

# Login
aws sso login --profile management-admin

# Use the profile
aws s3 ls --profile management-admin
```

### Programmatic Access

```python
# Python example using boto3
import boto3

session = boto3.Session(profile_name='management-admin')
s3 = session.client('s3')
response = s3.list_buckets()
```

## Session Durations

Choose appropriate session durations:

- **PT1H** (1 hour) - High-privilege operations, temporary access
- **PT2H** (2 hours) - Read-only users, auditors
- **PT4H** (4 hours) - Standard developers, operators
- **PT8H** (8 hours) - Full-time developers, administrators
- **PT12H** (12 hours) - Extended work sessions (maximum)

## Best Practices

### 1. Use Groups, Not Individual Users

❌ **Don't do this:**
```hcl
"john-admin" = {
  account_id       = "111111111111"
  permission_set   = "AdministratorAccess"
  principal_type   = "USER"
  principal_name   = "john_admin"
}
```

✅ **Do this:**
```hcl
"admins-account" = {
  account_id       = "111111111111"
  permission_set   = "AdministratorAccess"
  principal_type   = "GROUP"
  principal_name   = "administrators"
}
```

### 2. Implement Least Privilege

Start with minimal permissions and add as needed:

1. Start with `ReadOnlyAccess`
2. Add specific service permissions
3. Only grant `AdministratorAccess` when necessary
4. Use permissions boundaries when needed

### 3. Use Appropriate Session Durations

- Don't use PT12H for everyone
- Match session duration to role sensitivity
- Shorter sessions for privileged access

### 4. Organize Logically

```hcl
# Good: Descriptive names
"admins-prod-account" = { ... }
"devs-dev-account" = { ... }
"readonly-all-accounts" = { ... }

# Bad: Generic names
"assignment1" = { ... }
"assignment2" = { ... }
```

### 5. Tag Everything

```hcl
tags = {
  Environment  = "Management"
  ManagedBy    = "Terraform"
  Team         = "Security"
  CostCenter   = "IT"
  Compliance   = "SOC2"
}
```

### 6. Use External IdP for Enterprise

For organizations with existing identity management:
- Use Azure AD, Okta, Google Workspace, etc.
- Leverage existing groups and user management
- Enable SAML-based SSO
- Sync groups automatically (if supported)

## Troubleshooting

### Permission Set Not Applying

**Symptom**: User assigned but can't access account

**Solutions**:
1. Wait 5-10 minutes for propagation
2. Check account assignment exists:
   ```bash
   terraform output identity_center_account_assignments
   ```
3. Verify user is in correct group
4. Have user log out and back in

### External Group Not Found

**Symptom**: Error when applying Terraform

**Solutions**:
1. Verify group exists in your IdP
2. Check display name matches exactly (case-sensitive)
3. Ensure IdP sync is working
4. Check IAM Identity Center → Identity source

### Session Expired Too Quickly

**Symptom**: User session expires unexpectedly

**Solutions**:
1. Increase session duration in permission set:
   ```hcl
   session_duration = "PT8H"  # Increase from PT1H
   ```
2. Apply changes: `terraform apply`
3. Wait for propagation (5-10 minutes)
4. User must log out and back in

### Can't Enable IAM Identity Center

**Symptom**: Error when enabling

**Solutions**:
1. Ensure AWS Organizations is enabled
2. Use management account (not member account)
3. Enable in AWS Console first, then use Terraform
4. Check region - IAM Identity Center is region-specific

## Security Considerations

1. **MFA**: Enable MFA for all users (configured in Console or IdP)
2. **Least Privilege**: Start with minimal permissions
3. **Audit**: Monitor CloudTrail for IAM Identity Center events
4. **Session Duration**: Use short sessions for privileged access
5. **Permissions Boundaries**: Use boundaries to limit maximum permissions
6. **Regular Review**: Audit permissions and assignments quarterly

## Outputs

After deployment, useful outputs:

```bash
# View Identity Center instance ARN
terraform output identity_center_instance_arn

# View permission set ARNs
terraform output identity_center_permission_set_arns

# View account assignments
terraform output identity_center_account_assignments

# View groups
terraform output identity_center_group_ids

# View users
terraform output identity_center_user_ids
```

## Cost

**IAM Identity Center is FREE**

- No charge for users, groups, or permission sets
- No charge for account assignments
- No charge for SSO access

You only pay for:
- AWS resources accessed by users
- External IdP costs (if applicable)

## Related Modules

- `../modules/iam-identity-center/` - Identity Center module implementation

## References

- [IAM Identity Center Documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/)
- [Permission Sets](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html)
- [AWS CLI SSO](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [Best Practices](https://docs.aws.amazon.com/singlesignon/latest/userguide/best-practices.html)

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review AWS documentation
3. Check Terraform state: `terraform show`
4. View detailed logs: `terraform apply -debug`
