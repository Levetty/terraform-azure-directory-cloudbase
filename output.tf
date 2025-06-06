output "cloudbase_app_client_id" {
  description = "The Client ID of the Cloudbase App"
  value       = module.cloudbase-app.cloudbase_app_client_id
}

output "directory_id" {
  description = "The Azure Entra ID tenant/directory ID where Cloudbase resources will be created."
  value       = var.directory_id
}
