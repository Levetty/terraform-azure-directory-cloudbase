###############################################################################
# Required
###############################################################################
variable "cloudbase_app_sp_object_id" {
  description = <<EOT
  (required) The object ID of the Cloudbase Application Service Principal.

  ex: 00000000-0000-0000-0000-000000000000
  EOT
  type        = string
}

variable "root_management_group_id" {
  description = <<EOT
  (required) The ID of the root management group.

  ex: /providers/Microsoft.Management/managementGroups/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

variable "cspm_role_definition_id" {
  description = <<EOT
  (optional) The ID of the existing Cloudbase CSPM Role Definition. If specified, the module will not create a new role definition but will use this existing role definition.

  ex: /providers/Microsoft.Authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

variable "cwpp_role_definition_id" {
  description = <<EOT
  (optional) The ID of the existing Cloudbase CWPP Role Definition. If specified, the module will not create a new role definition but will use this existing role definition.

  ex: /providers/Microsoft.Authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

###############################################################################
# Optional 
###############################################################################
variable "enable_cnapp" {
  default     = true
  description = "(optional) Enable CNAPP functions. If it is true, both CSPM and CWPP role definitions will be created and assigned for comprehensive security scanning."
  type        = bool
}
variable "excluded_subscription_ids" {
  description = <<EOT
  (optional) A list of Azure subscription IDs where role assignments will not be applied. Please specify the subscriptions you want to disable with this module. If not specified, all subscriptions in the management group will be targeted.

  ex: ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"]
  EOT
  type        = list(string)
  default     = []
}

variable "auto_role_assignment_deployment_permissions" {
  description = <<EOT
  (optional) Specify the permissions for the auto role assignment deployment role.
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
