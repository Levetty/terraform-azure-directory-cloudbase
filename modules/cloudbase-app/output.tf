output "cloudbase_app_client_id" {
  description = "The Client ID of the Cloudbase App"
  value       = azuread_application.cloudbase_app.client_id
}

output "cloudbase_app_sp_object_id" {
  description = "The object ID of the Cloudbase App Service Principal"
  value       = azuread_service_principal.cloudbase_app_sp.object_id
}
