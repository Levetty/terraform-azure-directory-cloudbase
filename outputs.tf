output "cloudbase_app_application_id" {
  value = module.cloudbase-app.cloudbase_app_application_id
}

output "directory_id" {
  value = var.directory_id
}

// constants
output "cspm_role_def_name" {
  value = var.cspm_permissions.custom.role_def_name
}

output "cwpp_role_def_name" {
  value = var.cwpp_permissions.custom.role_def_name
}

output "auto_role_assignment_deployment_role_def_name" {
  value = var.auto_role_assignment_deployment_permissions.custom.role_def_name
}
