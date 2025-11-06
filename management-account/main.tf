# -----------------------------------------------------------------------------
# IAM Identity Center Module
# -----------------------------------------------------------------------------
module "identity_center" {
  count  = var.identity_center_enabled ? 1 : 0
  source = "../modules/iam-identity-center"

  # Identity Store Configuration
  create_identity_store_users  = var.create_identity_store_users
  create_identity_store_groups = var.create_identity_store_groups

  # Users and Groups
  users  = var.identity_center_users
  groups = var.identity_center_groups

  # Permission Sets
  permission_sets = var.identity_center_permission_sets

  # Account Assignments
  account_assignments = var.identity_center_account_assignments

  # External Identity Provider
  external_idp_enabled = var.external_idp_enabled
  external_groups      = var.external_groups
  external_users       = var.external_users

  # Tags
  tags = local.common_tags
}
