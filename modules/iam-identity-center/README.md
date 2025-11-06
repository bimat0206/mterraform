# IAM Identity Center Module

Terraform module for managing AWS IAM Identity Center (formerly AWS SSO) with support for permission sets, account assignments, Identity Store users/groups, and external identity providers.

## Features

- **Permission Sets**: Flexible permission set configuration with AWS managed, customer managed, and inline policies
- **Account Assignments**: Assign users and groups to AWS accounts with specific permission sets
- **Identity Store**: Create and manage users and groups in the Identity Store
- **External IdP**: Support for external identity providers (Azure AD, Okta, Google Workspace, etc.)
- **Group Memberships**: Automatic user to group assignments
- **Permissions Boundary**: Support for permissions boundaries on permission sets
- **Session Duration**: Configurable session duration per permission set
- **Modular Design**: Organized into separate files for easier troubleshooting
- **Production Ready**: Best practices for multi-account AWS Organizations

## Architecture

The module is organized into separate files for better maintainability:

- **data.tf**: Data sources, locals, and Identity Center instance discovery
- **identity_store.tf**: Identity Store users, groups, and memberships
- **permission_sets.tf**: Permission sets with policy attachments
- **account_assignments.tf**: User/group assignments to AWS accounts
- **versions.tf**: Provider version constraints
- **variables.tf**: Input variables
- **outputs.tf**: Output values and management commands

## Prerequisites

1. **AWS Organizations**: IAM Identity Center requires AWS Organizations
2. **Management Account**: Deploy this module in the management account
3. **Identity Center Enabled**: Enable IAM Identity Center in the AWS Console first
4. **Region**: IAM Identity Center is a global service but resources are created in a specific region

## Usage

### Basic Example - Internal Identity Store

```hcl
module "identity_center" {
  source = "../modules/iam-identity-center"

  # Create users and groups in Identity Store
  create_identity_store_users  = true
  create_identity_store_groups = true

  # Define groups
  groups = {
    administrators = {
      display_name = "Administrators"
      description  = "Full administrative access"
    }
    developers = {
      display_name = "Developers"
      description  = "Developer access"
    }
    readonly = {
      display_name = "ReadOnly"
      description  = "Read-only access"
    }
  }

  # Define users
  users = {
    john_doe = {
      user_name    = "john.doe"
      display_name = "John Doe"
      email        = "john.doe@example.com"
      first_name   = "John"
      last_name    = "Doe"
      group_memberships = ["administrators"]
    }
    jane_smith = {
      user_name    = "jane.smith"
      display_name = "Jane Smith"
      email        = "jane.smith@example.com"
      first_name   = "Jane"
      last_name    = "Smith"
      group_memberships = ["developers"]
    }
  }

  # Define permission sets
  permission_sets = {
    AdministratorAccess = {
      description      = "Full administrative access"
      session_duration = "PT8H"  # 8 hours
      aws_managed_policies = [
        "AdministratorAccess"
      ]
    }
    PowerUserAccess = {
      description      = "Power user access"
      session_duration = "PT4H"  # 4 hours
      aws_managed_policies = [
        "PowerUserAccess"
      ]
    }
    ReadOnlyAccess = {
      description      = "Read-only access"
      session_duration = "PT2H"  # 2 hours
      aws_managed_policies = [
        "ReadOnlyAccess"
      ]
    }
  }

  # Assign groups to accounts
  account_assignments = {
    "admins-prod" = {
      account_id       = "111111111111"
      permission_set   = "AdministratorAccess"
      principal_type   = "GROUP"
      principal_name   = "administrators"
    }
    "devs-dev" = {
      account_id       = "222222222222"
      permission_set   = "PowerUserAccess"
      principal_type   = "GROUP"
      principal_name   = "developers"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### External Identity Provider Example

```hcl
module "identity_center" {
  source = "../modules/iam-identity-center"

  # Using external IdP (Azure AD, Okta, etc.)
  external_idp_enabled = true

  # Do not create users/groups in Identity Store
  create_identity_store_users  = false
  create_identity_store_groups = false

  # Reference external groups (must exist in your IdP)
  external_groups = {
    administrators = {
      display_name = "AWS-Administrators"  # Group name from Azure AD/Okta
    }
    developers = {
      display_name = "AWS-Developers"
    }
    data_analysts = {
      display_name = "AWS-DataAnalysts"
    }
  }

  # Permission sets
  permission_sets = {
    AdministratorAccess = {
      description      = "Full administrative access"
      session_duration = "PT8H"
      aws_managed_policies = ["AdministratorAccess"]
    }
    DeveloperAccess = {
      description      = "Developer access"
      session_duration = "PT4H"
      aws_managed_policies = ["PowerUserAccess"]
    }
    DataAnalystAccess = {
      description      = "Data analyst access"
      session_duration = "PT4H"
      aws_managed_policies = [
        "AmazonAthenaFullAccess",
        "AmazonS3ReadOnlyAccess",
        "AWSGlueConsoleFullAccess"
      ]
    }
  }

  # Assign external groups to accounts
  account_assignments = {
    "admins-management" = {
      account_id       = "111111111111"
      permission_set   = "AdministratorAccess"
      principal_type   = "GROUP"
      principal_name   = "administrators"
    }
    "devs-dev-account" = {
      account_id       = "222222222222"
      permission_set   = "DeveloperAccess"
      principal_type   = "GROUP"
      principal_name   = "developers"
    }
    "analysts-data-account" = {
      account_id       = "333333333333"
      permission_set   = "DataAnalystAccess"
      principal_type   = "GROUP"
      principal_name   = "data_analysts"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Custom Policies

```hcl
module "identity_center" {
  source = "../modules/iam-identity-center"

  create_identity_store_users  = true
  create_identity_store_groups = true

  groups = {
    administrators = {
      display_name = "Administrators"
      description  = "Full administrative access"
    }
    developers = {
      display_name = "Developers"
      description  = "Developer access with deployment permissions"
    }
    readonly = {
      display_name = "ReadOnly"
      description  = "Read-only access across all services"
    }
    billing = {
      display_name = "Billing"
      description  = "Billing and cost management access"
    }
  }

  users = {
    admin_user = {
      user_name    = "admin"
      display_name = "Administrator"
      email        = "admin@example.com"
      first_name   = "Admin"
      last_name    = "User"
      group_memberships = ["administrators"]
    }
    dev_user = {
      user_name    = "developer"
      display_name = "Developer"
      email        = "developer@example.com"
      first_name   = "Dev"
      last_name    = "User"
      group_memberships = ["developers"]
    }
  }

  permission_sets = {
    # Full Admin Access
    AdministratorAccess = {
      description      = "Full administrative access"
      session_duration = "PT12H"
      aws_managed_policies = ["AdministratorAccess"]
      tags = {
        Compliance = "High-Risk"
      }
    }

    # Developer Access with inline policy
    DeveloperAccess = {
      description      = "Developer access with deployment permissions"
      session_duration = "PT8H"
      aws_managed_policies = [
        "PowerUserAccess"
      ]
      # Inline policy for additional permissions
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "eks:DescribeCluster",
              "eks:ListClusters",
              "eks:AccessKubernetesApi"
            ]
            Resource = "*"
          }
        ]
      })
    }

    # Read-Only with customer managed policy
    ReadOnlyAccess = {
      description      = "Read-only access"
      session_duration = "PT4H"
      aws_managed_policies = [
        "ReadOnlyAccess"
      ]
      customer_managed_policies = [
        {
          name = "CustomReadOnlyPolicy"
          path = "/"
        }
      ]
    }

    # Billing Access
    BillingAccess = {
      description      = "Billing and cost management access"
      session_duration = "PT4H"
      aws_managed_policies = [
        "job-function/Billing"
      ]
    }

    # S3 Admin with permissions boundary
    S3AdminAccess = {
      description      = "S3 administrative access with boundary"
      session_duration = "PT4H"
      aws_managed_policies = [
        "AmazonS3FullAccess"
      ]
      permissions_boundary = {
        managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
      }
    }

    # Custom Developer Access
    CustomDeveloperAccess = {
      description      = "Custom developer access"
      session_duration = "PT8H"
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:*",
              "lambda:*",
              "dynamodb:*",
              "sqs:*",
              "sns:*",
              "cloudformation:*",
              "cloudwatch:*",
              "logs:*",
              "ecr:*",
              "ecs:*"
            ]
            Resource = "*"
          },
          {
            Effect = "Deny"
            Action = [
              "iam:*",
              "organizations:*",
              "account:*"
            ]
            Resource = "*"
          }
        ]
      })
    }
  }

  # Multi-account assignments
  account_assignments = {
    # Management account
    "admins-management" = {
      account_id       = "111111111111"
      permission_set   = "AdministratorAccess"
      principal_type   = "GROUP"
      principal_name   = "administrators"
    }
    "billing-management" = {
      account_id       = "111111111111"
      permission_set   = "BillingAccess"
      principal_type   = "GROUP"
      principal_name   = "billing"
    }

    # Development account
    "devs-dev" = {
      account_id       = "222222222222"
      permission_set   = "DeveloperAccess"
      principal_type   = "GROUP"
      principal_name   = "developers"
    }
    "readonly-dev" = {
      account_id       = "222222222222"
      permission_set   = "ReadOnlyAccess"
      principal_type   = "GROUP"
      principal_name   = "readonly"
    }

    # Production account
    "admins-prod" = {
      account_id       = "333333333333"
      permission_set   = "AdministratorAccess"
      principal_type   = "GROUP"
      principal_name   = "administrators"
    }
    "readonly-prod" = {
      account_id       = "333333333333"
      permission_set   = "ReadOnlyAccess"
      principal_type   = "GROUP"
      principal_name   = "readonly"
    }

    # Specific user assignment
    "dev-user-dev-account" = {
      account_id       = "222222222222"
      permission_set   = "CustomDeveloperAccess"
      principal_type   = "USER"
      principal_name   = "dev_user"
    }
  }

  tags = {
    Environment  = "Production"
    Organization = "MyOrg"
    ManagedBy    = "Terraform"
    CostCenter   = "Security"
  }
}
```

## Permission Sets

### AWS Managed Policies

Use AWS-managed policies for common access patterns:

```hcl
permission_sets = {
  AdminAccess = {
    description      = "Full admin access"
    session_duration = "PT8H"
    aws_managed_policies = [
      "AdministratorAccess"
    ]
  }

  PowerUser = {
    description      = "Power user without IAM"
    session_duration = "PT4H"
    aws_managed_policies = [
      "PowerUserAccess"
    ]
  }

  ReadOnly = {
    description      = "Read-only access"
    session_duration = "PT2H"
    aws_managed_policies = [
      "ReadOnlyAccess"
    ]
  }

  ViewOnlyAccess = {
    description      = "View-only access"
    session_duration = "PT2H"
    aws_managed_policies = [
      "job-function/ViewOnlyAccess"
    ]
  }

  DataScientist = {
    description      = "Data scientist access"
    session_duration = "PT4H"
    aws_managed_policies = [
      "job-function/DataScientist"
    ]
  }

  NetworkAdministrator = {
    description      = "Network administrator access"
    session_duration = "PT4H"
    aws_managed_policies = [
      "job-function/NetworkAdministrator"
    ]
  }

  SecurityAudit = {
    description      = "Security auditor access"
    session_duration = "PT4H"
    aws_managed_policies = [
      "SecurityAudit"
    ]
  }
}
```

### Session Duration

Session duration format: ISO 8601 duration format

- `PT1H` - 1 hour
- `PT2H` - 2 hours
- `PT4H` - 4 hours (recommended for developers)
- `PT8H` - 8 hours (recommended for admins)
- `PT12H` - 12 hours (maximum)

### Inline Policies

For custom permissions:

```hcl
permission_sets = {
  CustomDeveloper = {
    description      = "Custom developer permissions"
    session_duration = "PT8H"
    inline_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:*",
            "lambda:*",
            "dynamodb:*"
          ]
          Resource = "*"
        }
      ]
    })
  }
}
```

### Permissions Boundary

Limit maximum permissions:

```hcl
permission_sets = {
  BoundedDeveloper = {
    description      = "Developer with boundary"
    session_duration = "PT8H"
    aws_managed_policies = ["PowerUserAccess"]
    permissions_boundary = {
      managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }
  }
}
```

## Account Assignments

### Group Assignments

Assign groups to multiple accounts:

```hcl
account_assignments = {
  "admins-prod" = {
    account_id       = "111111111111"
    permission_set   = "AdministratorAccess"
    principal_type   = "GROUP"
    principal_name   = "administrators"
  }
  "admins-dev" = {
    account_id       = "222222222222"
    permission_set   = "AdministratorAccess"
    principal_type   = "GROUP"
    principal_name   = "administrators"
  }
  "devs-dev" = {
    account_id       = "222222222222"
    permission_set   = "DeveloperAccess"
    principal_type   = "GROUP"
    principal_name   = "developers"
  }
}
```

### User Assignments

Assign specific users:

```hcl
account_assignments = {
  "john-prod-admin" = {
    account_id       = "111111111111"
    permission_set   = "AdministratorAccess"
    principal_type   = "USER"
    principal_name   = "john_doe"
  }
}
```

## External Identity Providers

### Supported Providers

- **Azure Active Directory (Azure AD / Entra ID)**
- **Okta**
- **Google Workspace**
- **OneLogin**
- **PingIdentity**
- **Any SAML 2.0 compatible IdP**

### Configuration Steps

1. **Enable external IdP in AWS Console**:
   - Go to IAM Identity Center
   - Settings → Identity Source
   - Choose "External identity provider"
   - Configure SAML 2.0 metadata

2. **Use module with external groups**:
```hcl
module "identity_center" {
  source = "../modules/iam-identity-center"

  external_idp_enabled = true

  external_groups = {
    aws_admins = {
      display_name = "AWS-Administrators"  # Must match IdP group name
    }
  }

  # ... rest of configuration
}
```

### Azure AD Integration

1. Create Enterprise Application in Azure AD
2. Configure SAML SSO
3. Map Azure AD groups to Identity Center
4. Use Azure AD group names in `external_groups`

### Okta Integration

1. Create AWS Single Sign-On app in Okta
2. Configure SAML 2.0
3. Assign Okta groups
4. Use Okta group names in `external_groups`

## Best Practices

### 1. Use Groups, Not Users

Always assign permissions via groups:

```hcl
# ✅ Good - Use groups
account_assignments = {
  "admins-prod" = {
    account_id       = "111111111111"
    permission_set   = "AdministratorAccess"
    principal_type   = "GROUP"
    principal_name   = "administrators"
  }
}

# ❌ Bad - Direct user assignment
account_assignments = {
  "john-prod" = {
    account_id       = "111111111111"
    permission_set   = "AdministratorAccess"
    principal_type   = "USER"
    principal_name   = "john_doe"
  }
}
```

### 2. Use Appropriate Session Durations

- **Admins**: PT8H-PT12H (8-12 hours)
- **Developers**: PT4H-PT8H (4-8 hours)
- **Read-only**: PT2H-PT4H (2-4 hours)
- **Privileged operations**: PT1H (1 hour)

### 3. Implement Least Privilege

Start with minimal permissions and add as needed:

```hcl
# Start with ReadOnly
permission_sets = {
  ReadOnlyAccess = {
    description      = "Read-only access"
    session_duration = "PT2H"
    aws_managed_policies = ["ReadOnlyAccess"]
  }
}

# Add specific permissions
permission_sets = {
  DeveloperAccess = {
    description      = "Developer access"
    session_duration = "PT4H"
    aws_managed_policies = ["PowerUserAccess"]
  }
}
```

### 4. Use Permissions Boundaries

Protect against privilege escalation:

```hcl
permission_sets = {
  BoundedAdmin = {
    description      = "Admin with boundary"
    session_duration = "PT8H"
    aws_managed_policies = ["AdministratorAccess"]
    permissions_boundary = {
      managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
    }
  }
}
```

### 5. Organize by Environment

Use clear naming and separation:

```hcl
account_assignments = {
  # Production - limited access
  "admins-prod"   = { ... }
  "readonly-prod" = { ... }

  # Development - broader access
  "devs-dev"      = { ... }
  "testers-dev"   = { ... }

  # Staging
  "devs-staging"  = { ... }
}
```

### 6. Tag Everything

```hcl
tags = {
  Environment  = "Production"
  ManagedBy    = "Terraform"
  Team         = "Security"
  CostCenter   = "IT"
  Compliance   = "SOC2"
}
```

## Troubleshooting

### Permission Set Not Applying

Wait for propagation (can take 5-10 minutes):

```bash
# Check permission set status
aws sso-admin describe-permission-set \
  --instance-arn <instance-arn> \
  --permission-set-arn <permission-set-arn>
```

### User Can't See Account

1. Check account assignment exists
2. Verify user is in correct group
3. Check permission set is provisioned
4. User needs to log out and back in

### External Group Not Found

Ensure group exists in your IdP and display name matches exactly:

```hcl
external_groups = {
  admins = {
    display_name = "AWS-Administrators"  # Must match IdP exactly
  }
}
```

### Session Duration Too Short

Update permission set:

```hcl
permission_sets = {
  MySet = {
    description      = "My permission set"
    session_duration = "PT8H"  # Increase from default PT1H
    # ...
  }
}
```

## Cost

IAM Identity Center is **free**. You only pay for:
- AWS resources accessed by users
- External IdP costs (if using Azure AD, Okta, etc.)

## Outputs

| Output | Description |
|--------|-------------|
| `instance_arn` | IAM Identity Center instance ARN |
| `identity_store_id` | Identity Store ID |
| `permission_set_arns` | Map of permission set ARNs |
| `group_ids` | Map of group IDs |
| `user_ids` | Map of user IDs |
| `account_assignments` | All account assignments |
| `permission_set_count` | Number of permission sets |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Important Notes

1. **Management Account Only**: This module must be deployed in the AWS Organizations management account
2. **Enable First**: Enable IAM Identity Center in AWS Console before running Terraform
3. **Global Service**: IAM Identity Center is global but region-specific
4. **Propagation Time**: Permission changes can take 5-10 minutes to propagate
5. **External IdP**: Configure external IdP in Console first, then reference in Terraform

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## References

- [IAM Identity Center Documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/)
- [Permission Sets](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html)
- [External Identity Providers](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-idp.html)
- [Best Practices](https://docs.aws.amazon.com/singlesignon/latest/userguide/best-practices.html)
