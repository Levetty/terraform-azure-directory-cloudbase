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

variable "subscription_ids" {
  description = <<EOT
  (required) A list of Azure subscription IDs where role assignments will be applied. Please specify the subscriptions you want to manage with this module.

  ex: ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"]
  EOT
  type        = list(string)
}

###############################################################################
# Optional 
###############################################################################
variable "enable_cnapp" {
  default     = true
  description = "(optional) Enable CNAPP functions. If it is true, both CSPM and CWPP role definitions will be created and assigned for comprehensive security scanning."
  type        = bool
}

variable "directory_connection_permissions" {
  description = <<EOT
  (optional) Specify the permissions for the directory connection role.
  EOT
  type = object({
    built_in = list(object({
      name        = string
      role_def_id = string
    }))
  })

  default = {
    built_in = []
  }
}

variable "cspm_permissions" {
  description = <<EOT
  (optional) Specify the permissions for the CSPM role.
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

variable "cwpp_permissions" {
  description = <<EOT
  (optional) Specify the permissions for the CWPP role.
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
