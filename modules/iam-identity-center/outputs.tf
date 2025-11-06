# -----------------------------------------------------------------------------
# Identity Center Instance Outputs
# -----------------------------------------------------------------------------
output "instance_arn" {
  description = "ARN of the IAM Identity Center instance"
  value       = local.instance_arn
}

output "identity_store_id" {
  description = "ID of the Identity Store"
  value       = local.identity_store_id
}

# -----------------------------------------------------------------------------
# Permission Set Outputs
# -----------------------------------------------------------------------------
output "permission_set_arns" {
  description = "Map of permission set names to ARNs"
  value       = local.permission_set_arns
}

output "permission_set_ids" {
  description = "Map of permission set names to IDs"
  value = {
    for k, v in aws_ssoadmin_permission_set.this : k => v.id
  }
}

output "permission_set_names" {
  description = "List of permission set names"
  value       = [for ps in aws_ssoadmin_permission_set.this : ps.name]
}

# -----------------------------------------------------------------------------
# Group Outputs
# -----------------------------------------------------------------------------
output "group_ids" {
  description = "Map of group names to group IDs"
  value       = local.group_ids
}

output "internal_group_ids" {
  description = "Map of internal Identity Store group names to group IDs"
  value = {
    for k, v in aws_identitystore_group.this : k => v.group_id
  }
}

output "external_group_ids" {
  description = "Map of external IdP group names to group IDs"
  value = var.external_idp_enabled ? {
    for k, v in data.aws_identitystore_group.external : k => v.group_id
  } : {}
}

# -----------------------------------------------------------------------------
# User Outputs
# -----------------------------------------------------------------------------
output "user_ids" {
  description = "Map of user names to user IDs"
  value       = local.user_ids
}

output "internal_user_ids" {
  description = "Map of internal Identity Store user names to user IDs"
  value = {
    for k, v in aws_identitystore_user.this : k => v.user_id
  }
}

output "external_user_ids" {
  description = "Map of external IdP user names to user IDs"
  value = var.external_idp_enabled ? {
    for k, v in data.aws_identitystore_user.external : k => v.user_id
  } : {}
}

# -----------------------------------------------------------------------------
# Account Assignment Outputs
# -----------------------------------------------------------------------------
output "account_assignments" {
  description = "Map of account assignments"
  value = {
    for k, v in aws_ssoadmin_account_assignment.this : k => {
      account_id       = v.target_id
      permission_set   = var.account_assignments[k].permission_set
      principal_type   = v.principal_type
      principal_id     = v.principal_id
      principal_name   = var.account_assignments[k].principal_name
    }
  }
}

output "account_assignment_count" {
  description = "Total number of account assignments"
  value       = length(aws_ssoadmin_account_assignment.this)
}

# -----------------------------------------------------------------------------
# Configuration Summary
# -----------------------------------------------------------------------------
output "permission_set_count" {
  description = "Total number of permission sets"
  value       = length(aws_ssoadmin_permission_set.this)
}

output "internal_group_count" {
  description = "Total number of internal Identity Store groups"
  value       = length(aws_identitystore_group.this)
}

output "internal_user_count" {
  description = "Total number of internal Identity Store users"
  value       = length(aws_identitystore_user.this)
}

output "external_groups_configured" {
  description = "Number of external IdP groups configured"
  value       = var.external_idp_enabled ? length(var.external_groups) : 0
}

output "external_users_configured" {
  description = "Number of external IdP users configured"
  value       = var.external_idp_enabled ? length(var.external_users) : 0
}

# -----------------------------------------------------------------------------
# Management Commands
# -----------------------------------------------------------------------------
output "list_instances_command" {
  description = "Command to list IAM Identity Center instances"
  value       = "aws sso-admin list-instances"
}

output "list_permission_sets_command" {
  description = "Command to list permission sets"
  value       = "aws sso-admin list-permission-sets --instance-arn ${local.instance_arn}"
}

output "list_account_assignments_command" {
  description = "Command to list account assignments for a specific account"
  value       = "aws sso-admin list-account-assignments --instance-arn ${local.instance_arn} --account-id <ACCOUNT_ID> --permission-set-arn <PERMISSION_SET_ARN>"
}

output "describe_permission_set_command" {
  description = "Command to describe a permission set"
  value       = "aws sso-admin describe-permission-set --instance-arn ${local.instance_arn} --permission-set-arn <PERMISSION_SET_ARN>"
}

output "aws_sso_portal_url" {
  description = "AWS SSO Portal URL (you need to configure this in AWS Console)"
  value       = "Access the AWS SSO portal URL from the AWS Console -> IAM Identity Center"
}
