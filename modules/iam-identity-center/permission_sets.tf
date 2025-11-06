# -----------------------------------------------------------------------------
# Permission Sets
# -----------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = local.instance_arn
  session_duration = each.value.session_duration
  relay_state      = each.value.relay_state != "" ? each.value.relay_state : null

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = each.key
    }
  )
}

# -----------------------------------------------------------------------------
# AWS Managed Policy Attachments
# -----------------------------------------------------------------------------
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for ps_key, ps in var.permission_sets : [
        for policy in ps.aws_managed_policies : {
          key                = "${ps_key}-${replace(policy, "/", "-")}"
          permission_set_key = ps_key
          policy_arn         = "arn:${data.aws_partition.current.partition}:iam::aws:policy/${policy}"
        }
      ]
    ]) : pair.key => pair
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
  managed_policy_arn = each.value.policy_arn
}

# -----------------------------------------------------------------------------
# Customer Managed Policy Attachments
# -----------------------------------------------------------------------------
resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for ps_key, ps in var.permission_sets : [
        for idx, policy in ps.customer_managed_policies : {
          key                = "${ps_key}-${policy.name}"
          permission_set_key = ps_key
          policy_name        = policy.name
          policy_path        = policy.path
        }
      ]
    ]) : pair.key => pair
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn

  customer_managed_policy_reference {
    name = each.value.policy_name
    path = each.value.policy_path
  }
}

# -----------------------------------------------------------------------------
# Inline Policies
# -----------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = {
    for ps_key, ps in var.permission_sets : ps_key => ps
    if ps.inline_policy != ""
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value.inline_policy
}

# -----------------------------------------------------------------------------
# Permissions Boundary
# -----------------------------------------------------------------------------
resource "aws_ssoadmin_permissions_boundary_attachment" "this" {
  for_each = {
    for ps_key, ps in var.permission_sets : ps_key => ps
    if ps.permissions_boundary != null
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn

  permissions_boundary {
    dynamic "customer_managed_policy_reference" {
      for_each = each.value.permissions_boundary.customer_managed_policy_reference != null ? [1] : []
      content {
        name = each.value.permissions_boundary.customer_managed_policy_reference.name
        path = each.value.permissions_boundary.customer_managed_policy_reference.path
      }
    }

    dynamic "managed_policy_arn" {
      for_each = each.value.permissions_boundary.managed_policy_arn != "" ? [1] : []
      content {
        value = each.value.permissions_boundary.managed_policy_arn
      }
    }
  }
}
