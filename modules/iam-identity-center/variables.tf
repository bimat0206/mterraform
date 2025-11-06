# -----------------------------------------------------------------------------
# IAM Identity Center Configuration
# -----------------------------------------------------------------------------
variable "create_identity_store_users" {
  type        = bool
  default     = false
  description = "Create users in Identity Center Identity Store (set to true if not using external IdP)"
}

variable "create_identity_store_groups" {
  type        = bool
  default     = false
  description = "Create groups in Identity Center Identity Store (set to true if not using external IdP)"
}

# -----------------------------------------------------------------------------
# Users (for Identity Store)
# -----------------------------------------------------------------------------
variable "users" {
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

# -----------------------------------------------------------------------------
# Groups (for Identity Store)
# -----------------------------------------------------------------------------
variable "groups" {
  type = map(object({
    display_name = string
    description  = string
  }))
  default     = {}
  description = "Map of groups to create in Identity Center Identity Store"
}

# -----------------------------------------------------------------------------
# Permission Sets
# -----------------------------------------------------------------------------
variable "permission_sets" {
  type = map(object({
    description          = string
    session_duration     = optional(string, "PT1H")
    relay_state          = optional(string, "")

    # AWS Managed Policies
    aws_managed_policies = optional(list(string), [])

    # Customer Managed Policies
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])

    # Inline Policy
    inline_policy = optional(string, "")

    # Permissions Boundary
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

# -----------------------------------------------------------------------------
# Account Assignments
# -----------------------------------------------------------------------------
variable "account_assignments" {
  type = map(object({
    account_id       = string
    permission_set   = string
    principal_type   = string  # USER or GROUP
    principal_name   = string  # User name or group name
  }))
  default     = {}
  description = "Map of account assignments (user/group to account with permission set)"
}

# -----------------------------------------------------------------------------
# External Identity Provider Configuration
# -----------------------------------------------------------------------------
variable "external_idp_enabled" {
  type        = bool
  default     = false
  description = "Whether using external identity provider (Azure AD, Okta, etc.)"
}

variable "external_groups" {
  type = map(object({
    display_name = string
  }))
  default     = {}
  description = "Map of external IdP groups (for assignments only, not created in Identity Store)"
}

variable "external_users" {
  type = map(object({
    user_name = string
  }))
  default     = {}
  description = "Map of external IdP users (for assignments only, not created in Identity Store)"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for all Identity Center resources"
}
