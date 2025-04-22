locals {
  principal_id = var.cloudbase_app_sp_object_id

  directory_connection_role = var.directory_connection_permissions
  cspm_role                 = var.cspm_permissions
  cwpp_role                 = var.cwpp_permissions
}

resource "azurerm_role_definition" "cspm" {
  name        = local.cspm_role.custom.role_def_name
  scope       = var.root_management_group_id
  description = "Custom role for Cloudbase CSPM"

  permissions {
    actions          = local.cspm_role.custom.permissions.actions
    not_actions      = local.cspm_role.custom.permissions.not_actions
    data_actions     = local.cspm_role.custom.permissions.data_actions
    not_data_actions = local.cspm_role.custom.permissions.not_data_actions
  }

  assignable_scopes = [var.root_management_group_id]
}

resource "azurerm_role_definition" "cwpp" {
  name        = local.cwpp_role.custom.role_def_name
  scope       = var.root_management_group_id
  description = "Custom role for Cloudbase CWPP"

  permissions {
    actions          = local.cwpp_role.custom.permissions.actions
    not_actions      = local.cwpp_role.custom.permissions.not_actions
    data_actions     = local.cwpp_role.custom.permissions.data_actions
    not_data_actions = local.cwpp_role.custom.permissions.not_data_actions
  }

  assignable_scopes = [var.root_management_group_id]
}

locals {
  cspm_role_def_id = azurerm_role_definition.cspm.role_definition_resource_id
  cwpp_role_def_id = azurerm_role_definition.cwpp.role_definition_resource_id
}

resource "azurerm_role_assignment" "directory_connection" {
  for_each = {
    for idx, role in local.directory_connection_role.built_in :
    role.name => role.role_def_id
  }

  scope                            = var.root_management_group_id
  role_definition_id               = each.value
  principal_id                     = local.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "cspm" {
  for_each = toset(var.subscription_ids)

  scope                            = "/subscriptions/${each.value}"
  role_definition_id               = "/subscriptions/${each.value}${local.cspm_role_def_id}"
  principal_id                     = local.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "cwpp" {
  for_each = var.enable_cnapp ? toset(var.subscription_ids) : toset([])

  scope                            = "/subscriptions/${each.value}"
  role_definition_id               = "/subscriptions/${each.value}${local.cwpp_role_def_id}"
  principal_id                     = local.principal_id
  skip_service_principal_aad_check = true
}

