###############################################################################
# Required
###############################################################################
variable "directory_id" {
  description = "(Required) The Azure Entra ID (formerly Azure AD) tenant/directory ID where Cloudbase resources will be created."
  type        = string
}

variable "federated_identity_credential" {
  type = object({
    audiences = list(string)
    issuer    = string
    subject   = string
  })
  description = "(Required) Federated Identity Credential for establishing secure connection between Azure and Cloudbase. These values are provided by Cloudbase during onboarding."
}

variable "always_recreate_cloudbase_app" {
  description = "(Optional) Controls whether to force recreation of the Cloudbase application. Set to true to create a new app with unique name on every apply. Set to false when using remote Terraform state to maintain existing resources."
  type        = bool
}

###############################################################################
# Optional 
###############################################################################
variable "excluded_subscription_ids" {
  description = <<EOT
  (Optional) List of Azure subscription IDs to exclude from Cloudbase role assignments. These subscriptions will not be monitored or protected by Cloudbase.

  Example: ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"]
  EOT
  type        = list(string)
  default     = []
}

variable "enable_cnapp" {
  default     = true
  description = "(Optional) Enable Cloud Native Application Protection Platform (CNAPP) functionality. When true, creates both CSPM (Cloud Security Posture Management) and CWPP (Cloud Workload Protection Platform) roles for comprehensive cloud security."
  type        = bool
}

variable "enable_autoassign" {
  default     = true
  description = "(Optional) Enable automatic role assignment for new subscriptions. When true, Azure Policy automatically assigns Cloudbase roles to any new subscription created in the tenant, ensuring continuous protection."
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
