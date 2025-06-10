###############################################################################
# Required
###############################################################################
variable "cloudbase_group_object_id" {
  description = <<EOT
  (Required) The object ID of the Cloudbase security group created by the cloudbase-app module.

  Example: 00000000-0000-0000-0000-000000000000
  EOT
  type        = string
}

variable "root_management_group_id" {
  description = <<EOT
  (Required) The ID of the root management group where custom role definitions will be created.

  Example: /providers/Microsoft.Management/managementGroups/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  EOT
  type        = string
}

###############################################################################
# Optional 
###############################################################################
variable "enable_cnapp" {
  default     = true
  description = "(Optional) Enable Cloud Native Application Protection Platform (CNAPP) functionality. When true, creates and assigns both CSPM (Cloud Security Posture Management) and CWPP (Cloud Workload Protection Platform) roles for comprehensive security coverage."
  type        = bool
}

variable "directory_connection_permissions" {
  description = <<EOT
  (Optional) Built-in role permissions for directory connection. This role enables Cloudbase to read Azure AD/Entra ID directory information for user and group management.
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
  (Optional) Permissions for Cloud Security Posture Management (CSPM) role. CSPM continuously monitors cloud resources for security misconfigurations and compliance violations. You can define custom permissions or use built-in roles.
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
  (Optional) Permissions for Cloud Workload Protection Platform (CWPP) role. CWPP provides runtime protection for cloud workloads including VMs, containers, and serverless functions. You can define custom permissions or use built-in roles.
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
