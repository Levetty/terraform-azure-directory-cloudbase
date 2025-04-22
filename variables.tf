###############################################################################
# Required
###############################################################################
variable "tenant_id" {
  description = "(required) The Azure Entra ID tenant ID"
  type        = string
}

variable "federated_identity_credential" {
  type = object({
    audiences = list(string)
    issuer    = string
    subject   = string
  })
  description = "(required) Federated Identity Credential for establishing a connection between your Azure environment and Cloudbase. Please provide the values supplied by Cloudbase."
}

variable "always_recreate_cloudbase_app" {
  description = "(optional) Controls whether to always recreate the cloudbase_app. When set to true, the application will be recreated (with a new name) even if it already exists. Set to false if you are using remote Terraform state."
  type        = bool
}

###############################################################################
# Optional 
###############################################################################
variable "excluded_subscription_ids" {
  description = <<EOT
  (optional) A list of Azure subscription IDs where role assignments will not be applied. Please specify the subscriptions you want to exclude.

  ex: ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"]
  EOT
  type        = list(string)
  default     = []
}

variable "enable_cnapp" {
  default     = true
  description = "(optional) Enable CNAPP functions. If it is true, both CSPM and CWPP role definitions will be created and assigned for comprehensive security scanning."
  type        = bool
}

variable "enable_autoassign" {
  default     = true
  description = "(optional) Enable automatic role assignment. If it is true, Azure Policy will automatically create new role assignments whenever a new subscription is created in the tenant."
  type        = bool
}

variable "directory_connection_permissions" {
  type = object({
    built_in = list(object({
      name        = string
      role_def_id = string
    }))
  })

  default = {
    built_in = [{
      name        = "Management Group Contributor Role"
      role_def_id = "/providers/Microsoft.Authorization/roleDefinitions/ac63b705-f282-497d-ac71-919bf39d939d"
    }]
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
    custom = {
      role_def_name = "CloudbaseCSPMRoleV20240906"
      permissions = {
        actions = [
          "*/read",
          "Microsoft.IoTSecurity/defenderSettings/downloadManagerActivation/action",
          "Microsoft.IoTSecurity/defenderSettings/packageDownloads/action",
          "Microsoft.Security/iotDefenderSettings/downloadManagerActivation/action",
          "Microsoft.Security/iotDefenderSettings/packageDownloads/action",
          "Microsoft.Security/iotSensors/downloadResetPassword/action",
        ],
        not_actions = [],
        data_actions = [
          "Microsoft.KeyVault/vaults/*/read",
          "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
          "*/metadata/read"
        ],
        not_data_actions = []
      }
    }
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
    custom = {
      role_def_name = "CloudbaseCWPPRoleV20240906"
      permissions = {
        actions = [
          "Microsoft.Resources/subscriptions/resourceGroups/write",
          "Microsoft.Resources/subscriptions/resourceGroups/delete",
          "Microsoft.Compute/snapshots/write",
          "Microsoft.Compute/snapshots/delete",
          "Microsoft.Compute/disks/beginGetAccess/action",
          "Microsoft.Compute/disks/endGetAccess/action",
          "Microsoft.Compute/snapshots/beginGetAccess/action",
          "Microsoft.Compute/snapshots/endGetAccess/action",
          "Microsoft.Storage/storageAccounts/listkeys/action",
          "Microsoft.Web/sites/config/list/action",
          "Microsoft.Web/sites/publishxml/Action"
        ],
        not_actions      = [],
        data_actions     = [],
        not_data_actions = []
      }
    }
    built_in = []
  }
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
    custom = {
      role_def_name = "CloudbaseAutoRoleAssignmentDeploymentRoleV20250423"
      permissions = {
        actions = [
          "Microsoft.Authorization/roleAssignments/read",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.Resources/subscriptions/read",
          "Microsoft.Resources/deployments/*",
        ],
        not_actions      = [],
        data_actions     = [],
        not_data_actions = []
      }
    }
    built_in = []
  }
}
