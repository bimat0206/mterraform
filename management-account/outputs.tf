# -----------------------------------------------------------------------------
# IAM Identity Center Outputs
# -----------------------------------------------------------------------------
output "identity_center_instance_arn" {
  description = "ARN of the IAM Identity Center instance (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].instance_arn : null
}

output "identity_center_identity_store_id" {
  description = "ID of the Identity Store (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].identity_store_id : null
}

output "identity_center_permission_set_arns" {
  description = "Map of permission set names to ARNs (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].permission_set_arns : null
}

output "identity_center_permission_set_names" {
  description = "List of permission set names (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].permission_set_names : null
}

output "identity_center_group_ids" {
  description = "Map of group names to group IDs (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].group_ids : null
}

output "identity_center_user_ids" {
  description = "Map of user names to user IDs (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].user_ids : null
}

output "identity_center_account_assignments" {
  description = "Map of account assignments (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].account_assignments : null
}

output "identity_center_account_assignment_count" {
  description = "Total number of account assignments (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].account_assignment_count : null
}

output "identity_center_permission_set_count" {
  description = "Total number of permission sets (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].permission_set_count : null
}

output "identity_center_internal_group_count" {
  description = "Total number of internal Identity Store groups (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].internal_group_count : null
}

output "identity_center_internal_user_count" {
  description = "Total number of internal Identity Store users (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].internal_user_count : null
}

output "identity_center_list_instances_command" {
  description = "Command to list IAM Identity Center instances (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].list_instances_command : null
}

output "identity_center_list_permission_sets_command" {
  description = "Command to list permission sets (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].list_permission_sets_command : null
}

output "identity_center_list_account_assignments_command" {
  description = "Command to list account assignments (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].list_account_assignments_command : null
}

output "identity_center_aws_sso_portal_url" {
  description = "AWS SSO Portal URL information (if enabled)"
  value       = var.identity_center_enabled ? module.identity_center[0].aws_sso_portal_url : null
}
