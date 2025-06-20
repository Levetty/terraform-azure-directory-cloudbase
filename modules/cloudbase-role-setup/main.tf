locals {
  principal_id = var.cloudbase_group_object_id

  directory_connection_role = var.directory_connection_permissions
  cspm_role                 = var.cspm_permissions
  cwpp_role                 = var.cwpp_permissions

  # Check if roles have data actions
  cspm_has_data_actions = length(var.cspm_permissions.custom.permissions.data_actions) > 0
  cwpp_has_data_actions = var.enable_cnapp && length(var.cwpp_permissions.custom.permissions.data_actions) > 0
}

# Create CSPM role WITHOUT data actions initially if data actions exist
resource "azurerm_role_definition" "cspm" {
  name        = local.cspm_role.custom.role_def_name
  scope       = var.root_management_group_id
  description = "Custom role for Cloudbase CSPM"

  permissions {
    actions     = local.cspm_role.custom.permissions.actions
    not_actions = local.cspm_role.custom.permissions.not_actions
    # Initially create without data actions if they exist (will be added later)
    data_actions     = local.cspm_has_data_actions ? [] : local.cspm_role.custom.permissions.data_actions
    not_data_actions = local.cspm_has_data_actions ? [] : local.cspm_role.custom.permissions.not_data_actions
  }

  assignable_scopes = [var.root_management_group_id]

  lifecycle {
    # Always ignore changes to permissions since we may update them via Azure CLI
    ignore_changes = [permissions]
  }
}

resource "azurerm_role_definition" "cwpp" {
  count       = var.enable_cnapp ? 1 : 0
  name        = local.cwpp_role.custom.role_def_name
  scope       = var.root_management_group_id
  description = "Custom role for Cloudbase CWPP"

  permissions {
    actions     = local.cwpp_role.custom.permissions.actions
    not_actions = local.cwpp_role.custom.permissions.not_actions
    # Initially create without data actions if they exist (will be added later)
    data_actions     = local.cwpp_has_data_actions ? [] : local.cwpp_role.custom.permissions.data_actions
    not_data_actions = local.cwpp_has_data_actions ? [] : local.cwpp_role.custom.permissions.not_data_actions
  }

  assignable_scopes = [var.root_management_group_id]

  lifecycle {
    # Always ignore changes to permissions since we may update them via Azure CLI
    ignore_changes = [permissions]
  }
}

locals {
  cspm_role_def_id = azurerm_role_definition.cspm.role_definition_resource_id
  cwpp_role_def_id = var.enable_cnapp ? azurerm_role_definition.cwpp[0].role_definition_resource_id : ""
}

# Add data actions to roles AFTER assignment at management group level
resource "null_resource" "update_cspm_data_actions" {
  count = local.cspm_has_data_actions ? 1 : 0

  # Ensure role is created and assigned before updating
  depends_on = [
    azurerm_role_definition.cspm,
    azurerm_role_assignment.cspm_mgmt_group
  ]

  triggers = {
    role_id          = azurerm_role_definition.cspm.id
    role_name        = local.cspm_role.custom.role_def_name
    data_actions     = jsonencode(local.cspm_role.custom.permissions.data_actions)
    not_data_actions = jsonencode(local.cspm_role.custom.permissions.not_data_actions)
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for role assignment to propagate
      sleep 30
      
      # Get the role definition
      ROLE_DEF=$(az role definition list --name "${self.triggers.role_name}" --query "[0]" -o json)
      
      # Check if data actions already exist
      EXISTING_DATA_ACTIONS=$(echo "$ROLE_DEF" | jq -r '.permissions[0].dataActions | length')
      
      if [ "$EXISTING_DATA_ACTIONS" -gt 0 ]; then
        echo "Data actions already exist in role definition. Skipping update."
        exit 0
      fi
      
      # Update the role definition with data actions
      echo "$ROLE_DEF" | jq '.permissions[0].dataActions = ${self.triggers.data_actions} | .permissions[0].notDataActions = ${self.triggers.not_data_actions}' > /tmp/role_update.json
      
      # Apply the update
      az role definition update --role-definition @/tmp/role_update.json
      
      # Clean up
      rm -f /tmp/role_update.json
    EOT
  }
}

resource "null_resource" "update_cwpp_data_actions" {
  count = var.enable_cnapp && local.cwpp_has_data_actions ? 1 : 0

  depends_on = [
    azurerm_role_definition.cwpp[0],
    azurerm_role_assignment.cwpp_mgmt_group[0]
  ]

  triggers = {
    role_id          = azurerm_role_definition.cwpp[0].id
    role_name        = local.cwpp_role.custom.role_def_name
    data_actions     = jsonencode(local.cwpp_role.custom.permissions.data_actions)
    not_data_actions = jsonencode(local.cwpp_role.custom.permissions.not_data_actions)
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for role assignment to propagate
      sleep 30
      
      # Get the role definition
      ROLE_DEF=$(az role definition list --name "${self.triggers.role_name}" --query "[0]" -o json)
      
      # Check if data actions already exist
      EXISTING_DATA_ACTIONS=$(echo "$ROLE_DEF" | jq -r '.permissions[0].dataActions | length')
      
      if [ "$EXISTING_DATA_ACTIONS" -gt 0 ]; then
        echo "Data actions already exist in role definition. Skipping update."
        exit 0
      fi
      
      # Update the role definition with data actions
      echo "$ROLE_DEF" | jq '.permissions[0].dataActions = ${self.triggers.data_actions} | .permissions[0].notDataActions = ${self.triggers.not_data_actions}' > /tmp/role_update_cwpp.json
      
      # Apply the update
      az role definition update --role-definition @/tmp/role_update_cwpp.json
      
      # Clean up
      rm -f /tmp/role_update_cwpp.json
    EOT
  }
}

resource "azurerm_role_assignment" "directory_connection" {
  for_each = {
    for idx, role in local.directory_connection_role.built_in :
    role.name => role.role_def_id
  }

  scope              = var.root_management_group_id
  role_definition_id = each.value
  principal_id       = local.principal_id
}

# Management group level assignment for CSPM (before data actions are added)
resource "azurerm_role_assignment" "cspm_mgmt_group" {
  scope              = var.root_management_group_id
  role_definition_id = local.cspm_role_def_id
  principal_id       = local.principal_id
}

# Management group level assignment for CWPP (before data actions are added)
resource "azurerm_role_assignment" "cwpp_mgmt_group" {
  count              = var.enable_cnapp ? 1 : 0
  scope              = var.root_management_group_id
  role_definition_id = local.cwpp_role_def_id
  principal_id       = local.principal_id
}
