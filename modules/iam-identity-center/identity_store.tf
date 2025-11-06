# -----------------------------------------------------------------------------
# Identity Store Groups
# -----------------------------------------------------------------------------
resource "aws_identitystore_group" "this" {
  for_each = var.create_identity_store_groups ? var.groups : {}

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  description       = each.value.description
}

# -----------------------------------------------------------------------------
# Identity Store Users
# -----------------------------------------------------------------------------
resource "aws_identitystore_user" "this" {
  for_each = var.create_identity_store_users ? var.users : {}

  identity_store_id = local.identity_store_id
  user_name         = each.value.user_name
  display_name      = each.value.display_name

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }
}

# -----------------------------------------------------------------------------
# Group Memberships
# -----------------------------------------------------------------------------
resource "aws_identitystore_group_membership" "this" {
  for_each = var.create_identity_store_users && var.create_identity_store_groups ? {
    for pair in flatten([
      for user_key, user in var.users : [
        for group in user.group_memberships : {
          key        = "${user_key}-${group}"
          user_key   = user_key
          group_key  = group
        }
      ]
    ]) : pair.key => pair
  } : {}

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_key].group_id
  member_id         = aws_identitystore_user.this[each.value.user_key].user_id
}

# -----------------------------------------------------------------------------
# Data Sources for External Identity Provider Groups
# -----------------------------------------------------------------------------
data "aws_identitystore_group" "external" {
  for_each = var.external_idp_enabled ? var.external_groups : {}

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.display_name
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources for External Identity Provider Users
# -----------------------------------------------------------------------------
data "aws_identitystore_user" "external" {
  for_each = var.external_idp_enabled ? var.external_users : {}

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.user_name
    }
  }
}
