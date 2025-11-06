# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for management account resources"
}

variable "org_prefix" {
  type        = string
  description = "Organization prefix for resource naming"
}

variable "environment" {
  type        = string
  default     = "management"
  description = "Environment name"
}

variable "workload" {
  type        = string
  default     = "org"
  description = "Workload name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}

# -----------------------------------------------------------------------------
# IAM Identity Center Variables
# -----------------------------------------------------------------------------
variable "identity_center_enabled" {
  type        = bool
  default     = false
  description = "Enable IAM Identity Center configuration"
}

variable "create_identity_store_users" {
  type        = bool
  default     = false
  description = "Create users in Identity Center Identity Store"
}

variable "create_identity_store_groups" {
  type        = bool
  default     = false
  description = "Create groups in Identity Center Identity Store"
}

variable "identity_center_users" {
  type = map(object({
    user_name    = string
    display_name = string
    email        = string
    first_name   = string
    last_name    = string
    group_memberships = optional(list(string), [])
  }))
  default     = {}
  description = "Map of users to create in Identity Center Identity Store"
}

variable "identity_center_groups" {
  type = map(object({
    display_name = string
    description  = string
  }))
  default     = {}
  description = "Map of groups to create in Identity Center Identity Store"
}

variable "identity_center_permission_sets" {
  type = map(object({
    description          = string
    session_duration     = optional(string, "PT1H")
    relay_state          = optional(string, "")
    aws_managed_policies = optional(list(string), [])
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])
    inline_policy = optional(string, "")
    permissions_boundary = optional(object({
      customer_managed_policy_reference = optional(object({
        name = string
        path = optional(string, "/")
      }), null)
      managed_policy_arn = optional(string, "")
    }), null)
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of permission sets to create"
}

variable "identity_center_account_assignments" {
  type = map(object({
    account_id       = string
    permission_set   = string
    principal_type   = string
    principal_name   = string
  }))
  default     = {}
  description = "Map of account assignments"
}

variable "external_idp_enabled" {
  type        = bool
  default     = false
  description = "Whether using external identity provider"
}

variable "external_groups" {
  type = map(object({
    display_name = string
  }))
  default     = {}
  description = "Map of external IdP groups"
}

variable "external_users" {
  type = map(object({
    user_name = string
  }))
  default     = {}
  description = "Map of external IdP users"
}
