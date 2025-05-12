terraform {
  required_version = "~> 1.11"
  required_providers {
    azuread = "~> 3.3"
    azurerm = "~> 4.26"
  }
}
provider "azuread" {
  tenant_id = var.tenant_id
}
provider "azurerm" {
  features {}
}

// resource
data "azurerm_management_group" "root" {
  display_name = "Tenant Root Group"
}
data "azurerm_subscriptions" "all" {}
locals {
  enabled_subscriptions = [
    for sub in data.azurerm_subscriptions.all.subscriptions : sub.subscription_id
    if sub.state == "Enabled" && !contains(var.excluded_subscription_ids, sub.subscription_id)
  ]
  cloudbase_role_name = {
    cspm                            = var.cspm_permissions.custom.role_def_name
    cwpp                            = var.cwpp_permissions.custom.role_def_name
    auto_role_assignment_deployment = var.auto_role_assignment_deployment_permissions.custom.role_def_name
  }
}

module "cloudbase_app" {
  source                        = "./modules/cloudbase_app"
  federated_identity_credential_directory_scan = var.federated_identity_credential_directory_scan
  federated_identity_credential_security_scan = var.federated_identity_credential_security_scan
  always_recreate_cloudbase_app = var.always_recreate_cloudbase_app
}
module "cloudbase_role_setup" {
  source = "./modules/cloudbase_role_setup"

  enable_cnapp               = var.enable_cnapp
  cloudbase_app_sp_object_id = module.cloudbase_app.cloudbase_app_sp_object_id
  root_management_group_id   = data.azurerm_management_group.root.id
  subscription_ids           = local.enabled_subscriptions

  // permissions
  directory_connection_permissions = var.directory_connection_permissions
  cspm_permissions                 = var.cspm_permissions
  cwpp_permissions                 = var.cwpp_permissions

  depends_on = [module.cloudbase_app]
}
module "cloudbase_role_automation" {
  count  = var.enable_autoassign ? 1 : 0
  source = "./modules/cloudbase_role_automation"

  enable_cnapp               = var.enable_cnapp
  cloudbase_app_sp_object_id = module.cloudbase_app.cloudbase_app_sp_object_id
  excluded_subscription_ids  = var.excluded_subscription_ids
  root_management_group_id   = data.azurerm_management_group.root.id

  // role_def_id
  cspm_role_definition_id = module.cloudbase_role_setup.cspm_role_definition_id
  cwpp_role_definition_id = module.cloudbase_role_setup.cwpp_role_definition_id

  // premissions
  auto_role_assignment_deployment_permissions = var.auto_role_assignment_deployment_permissions

  depends_on = [module.cloudbase_app, module.cloudbase_role_setup]
}

// output
output "cloudbase_app_application_id" {
  value = module.cloudbase_app.cloudbase_app_application_id
}

output "cloudbase_app_sp_object_id" {
  value = module.cloudbase_app.cloudbase_app_sp_object_id
}

