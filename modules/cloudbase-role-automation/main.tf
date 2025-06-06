locals {
  principal_id = var.cloudbase_app_sp_object_id

  auto_role_assignment_deployment_role = var.auto_role_assignment_deployment_permissions

  cspm_role_def_id = var.cspm_role_definition_id
  cwpp_role_def_id = var.cwpp_role_definition_id

  # Generate scopes for excluded subscriptions
  excluded_subscription_scopes = [for sub_id in var.excluded_subscription_ids : "/subscriptions/${sub_id}"]
}

// Azure policy
resource "azurerm_role_definition" "auto_role_assignment_deployment" {
  name        = local.auto_role_assignment_deployment_role.custom.role_def_name
  scope       = var.root_management_group_id
  description = "Custom role for Cloudbase Auto Role Assignment Deployment"

  permissions {
    actions     = local.auto_role_assignment_deployment_role.custom.permissions.actions
    not_actions = local.auto_role_assignment_deployment_role.custom.permissions.not_actions
  }

  assignable_scopes = [
    var.root_management_group_id
  ]
}

locals {
  autoassign_role_def_id = azurerm_role_definition.auto_role_assignment_deployment.role_definition_resource_id
}

// azure policy
// cspm
resource "azurerm_policy_definition" "autoassign_role_cspm" {
  name                = "cloudbase-autoassign-cspm-${substr(local.principal_id, 0, 8)}"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Cloudbase Auto-Assign CSPM Role"
  description         = "This is Cloudbase Auto Assign Role to Subscriptions for ${local.principal_id} (Azure Application ID). This policy automatically assigns the Cloudbase CSPM role to all subscriptions in the tenant."
  management_group_id = var.root_management_group_id

  metadata = jsonencode({
    category = "Cloudbase AutoAssign"
  })

  policy_rule = templatefile("${path.module}/policy_rules/autoassign_policy_rule.json", {
    autoassign_role_def_id = local.autoassign_role_def_id
    principal_id           = local.principal_id
    role_def_id            = local.cspm_role_def_id
  })
}

// cwpp
resource "azurerm_policy_definition" "autoassign_role_cwpp" {
  count               = var.enable_cnapp ? 1 : 0
  name                = "cloudbase-autoassign-cwpp-${substr(local.principal_id, 0, 8)}"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Cloudbase Auto-Assign CWPP Role"
  description         = "This is Cloudbase Auto Assign Role to Subscriptions for ${local.principal_id} (Azure Application ID). This policy automatically assigns the Cloudbase CWPP role to all subscriptions in the tenant."
  management_group_id = var.root_management_group_id

  metadata = jsonencode({
    category = "Cloudbase AutoAssign"
  })

  policy_rule = templatefile("${path.module}/policy_rules/autoassign_policy_rule.json", {
    autoassign_role_def_id = local.autoassign_role_def_id
    principal_id           = local.principal_id
    role_def_id            = local.cwpp_role_def_id
  })
}

resource "azurerm_policy_set_definition" "autoassign_initiative" {
  name                = "cloudbase-autoassign-${substr(local.principal_id, 0, 8)}"
  policy_type         = "Custom"
  display_name        = "Cloudbase Auto-Assign Roles Initiative"
  description         = "This is Cloudbase Auto Assign Role to Subscriptions for ${local.principal_id} (Azure Application ID). This policy automatically assigns the Cloudbase role to all subscriptions in the tenant."
  management_group_id = var.root_management_group_id

  metadata = jsonencode({
    category = "Cloudbase"
    version  = "0.0.1"
  })

  policy_definition_reference {
    reference_id         = "AutoAssignCSPMRole"
    policy_definition_id = azurerm_policy_definition.autoassign_role_cspm.id
  }

  dynamic "policy_definition_reference" {
    for_each = var.enable_cnapp ? [1] : []
    content {
      reference_id         = "AutoAssignCWPPRole"
      policy_definition_id = azurerm_policy_definition.autoassign_role_cwpp[0].id
    }
  }
}

resource "azurerm_management_group_policy_assignment" "autoassign_initiative" {
  name                 = "cloudbase-${substr(local.principal_id, 0, 8)}"
  display_name         = "Cloudbase Auto-Assign Roles Initiative"
  description          = "This is Cloudbase Auto Assign Role to Subscriptions for ${local.principal_id} (Azure Application ID). This policy automatically assigns the Cloudbase role to all subscriptions in the tenant."
  management_group_id  = var.root_management_group_id
  policy_definition_id = azurerm_policy_set_definition.autoassign_initiative.id
  not_scopes           = local.excluded_subscription_scopes
  location             = "japaneast"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "autoassign_role_initiative" {
  scope                            = var.root_management_group_id
  role_definition_id               = local.autoassign_role_def_id
  principal_id                     = azurerm_management_group_policy_assignment.autoassign_initiative.identity[0].principal_id
  skip_service_principal_aad_check = true
}
