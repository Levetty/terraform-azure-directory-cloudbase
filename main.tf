provider "azuread" {
  tenant_id = var.directory_id
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

module "cloudbase-app" {
  source                                       = "./modules/cloudbase-app"
  federated_identity_credential_directory_scan = var.federated_identity_credential_directory_scan
  federated_identity_credential_security_scan  = var.federated_identity_credential_security_scan
  always_recreate_cloudbase_app                = var.always_recreate_cloudbase_app
}
module "cloudbase-role-setup" {
  source = "./modules/cloudbase-role-setup"

  enable_cnapp               = var.enable_cnapp
  cloudbase_app_sp_object_id = module.cloudbase-app.cloudbase_app_sp_object_id
  root_management_group_id   = data.azurerm_management_group.root.id
  subscription_ids           = local.enabled_subscriptions

  // permissions
  directory_connection_permissions = var.directory_connection_permissions
  cspm_permissions                 = var.cspm_permissions
  cwpp_permissions                 = var.cwpp_permissions

  depends_on = [module.cloudbase-app]
}
module "cloudbase-role-automation" {
  count  = var.enable_autoassign ? 1 : 0
  source = "./modules/cloudbase-role-automation"

  enable_cnapp               = var.enable_cnapp
  cloudbase_app_sp_object_id = module.cloudbase-app.cloudbase_app_sp_object_id
  excluded_subscription_ids  = var.excluded_subscription_ids
  root_management_group_id   = data.azurerm_management_group.root.id

  // role_def_id
  cspm_role_definition_id = module.cloudbase-role-setup.cspm_role_definition_id
  cwpp_role_definition_id = module.cloudbase-role-setup.cwpp_role_definition_id

  // premissions
  auto_role_assignment_deployment_permissions = var.auto_role_assignment_deployment_permissions

  depends_on = [module.cloudbase-app, module.cloudbase-role-setup]
}

