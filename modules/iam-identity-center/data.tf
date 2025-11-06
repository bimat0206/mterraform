# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# IAM Identity Center Instance
data "aws_ssoadmin_instances" "this" {}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------
locals {
  # Identity Center Instance ARN and Identity Store ID
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Combine internal and external groups
  all_groups = merge(
    var.create_identity_store_groups ? var.groups : {},
    var.external_idp_enabled ? var.external_groups : {}
  )

  # Combine internal and external users
  all_users = merge(
    var.create_identity_store_users ? var.users : {},
    var.external_idp_enabled ? var.external_users : {}
  )

  # Create group name to ID mapping
  group_ids = merge(
    {
      for k, v in aws_identitystore_group.this : k => v.group_id
    },
    var.external_idp_enabled ? {
      for k, v in data.aws_identitystore_group.external : k => v.group_id
    } : {}
  )

  # Create user name to ID mapping
  user_ids = merge(
    {
      for k, v in aws_identitystore_user.this : k => v.user_id
    },
    var.external_idp_enabled ? {
      for k, v in data.aws_identitystore_user.external : k => v.user_id
    } : {}
  )

  # Create permission set name to ARN mapping
  permission_set_arns = {
    for k, v in aws_ssoadmin_permission_set.this : k => v.arn
  }

  # Tags
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Service   = "IAM-Identity-Center"
    }
  )
}
