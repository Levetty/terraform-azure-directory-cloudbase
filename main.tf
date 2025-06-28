provider "azuread" {
  tenant_id = var.directory_id
}
provider "azurerm" {
  subscription_id = var.subscription_id == "" ? null : var.subscription_id
  features {}
}

// resource
data "azurerm_management_group" "root" {
  display_name = "Tenant Root Group"
}

locals {
  cloudbase_role_name = {
    cspm = var.cspm_permissions.custom.role_def_name
    cwpp = var.cwpp_permissions.custom.role_def_name
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

  enable_cnapp              = var.enable_cnapp
  cloudbase_group_object_id = module.cloudbase-app.cloudbase_group_object_id
  root_management_group_id  = data.azurerm_management_group.root.id

  // permissions
  directory_connection_permissions = var.directory_connection_permissions
  cspm_permissions                 = var.cspm_permissions
  cwpp_permissions                 = var.cwpp_permissions

  depends_on = [module.cloudbase-app]
}
