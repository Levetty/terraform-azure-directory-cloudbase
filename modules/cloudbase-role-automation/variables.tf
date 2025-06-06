###############################################################################
# Required
###############################################################################
variable "cloudbase_app_sp_object_id" {
  description = <<EOT
  (Required) The object ID of the Cloudbase Application Service Principal created by the cloudbase-app module.

  Example: 00000000-0000-0000-0000-000000000000
  EOT
  type        = string
}

variable "root_management_group_id" {
  description = <<EOT
  (Required) The ID of the root management group where Azure Policy definitions and assignments will be created for automatic role assignment.

  Example: /providers/Microsoft.Management/managementGroups/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

variable "cspm_role_definition_id" {
  description = <<EOT
  (Required) The ID of the existing Cloudbase CSPM (Cloud Security Posture Management) role definition created by the cloudbase-role-setup module. This role will be automatically assigned to new subscriptions.

  Example: /providers/Microsoft.Authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

variable "cwpp_role_definition_id" {
  description = <<EOT
  (Required) The ID of the existing Cloudbase CWPP (Cloud Workload Protection Platform) role definition created by the cloudbase-role-setup module. This role will be automatically assigned to new subscriptions.

  Example: /providers/Microsoft.Authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

###############################################################################
# Optional 
###############################################################################
variable "enable_cnapp" {
  default     = true
  description = "(Optional) Enable Cloud Native Application Protection Platform (CNAPP) functionality. When true, Azure Policy will automatically assign both CSPM and CWPP roles to new subscriptions for comprehensive security coverage."
  type        = bool
}
variable "excluded_subscription_ids" {
  description = <<EOT
  (Optional) List of Azure subscription IDs to exclude from automatic role assignments. These subscriptions will not receive Cloudbase roles when created. If not specified, all new subscriptions in the management group will be protected.

  Example: ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"]
  EOT
  type        = list(string)
  default     = []
}

variable "auto_role_assignment_deployment_permissions" {
  description = <<EOT
  (Optional) Permissions for the deployment role used by Azure Policy to automatically assign Cloudbase roles to new subscriptions. This role enables the policy remediation task to create role assignments.
  EOT
  type = object({
    custom = object({
      role_def_name = string
      permissions = object({
        actions          = list(string)
        not_actions      = list(string)
        data_actions     = list(string)
        not_data_actions = list(string)
      })
    })
    built_in = list(object({
      name        = string
      role_def_id = string
    }))
  })
  default = {
    custom   = null
    built_in = []
  }
}
