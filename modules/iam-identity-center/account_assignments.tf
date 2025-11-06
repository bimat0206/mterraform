# -----------------------------------------------------------------------------
# Account Assignments
# -----------------------------------------------------------------------------
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.account_assignments

  instance_arn       = local.instance_arn
  permission_set_arn = local.permission_set_arns[each.value.permission_set]

  principal_id   = each.value.principal_type == "GROUP" ? local.group_ids[each.value.principal_name] : local.user_ids[each.value.principal_name]
  principal_type = each.value.principal_type

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
