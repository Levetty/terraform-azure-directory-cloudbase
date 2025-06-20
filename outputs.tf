output "cloudbase_app_application_id" {
  value = module.cloudbase-app.cloudbase_app_client_id
}

output "cloudbase_group_object_id" {
  value       = module.cloudbase-app.cloudbase_group_object_id
  description = "The object ID of the Cloudbase security group"
}

output "directory_id" {
  value = var.directory_id
}

output "cspm_role_def_name" {
  value = var.cspm_permissions.custom.role_def_name
}

output "cwpp_role_def_name" {
  value = var.cwpp_permissions.custom.role_def_name
}
