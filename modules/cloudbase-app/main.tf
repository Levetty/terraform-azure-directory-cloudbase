locals {
  now_utc = formatdate("YYYYMMDDhhmm", timestamp())
}

data "azuread_application_published_app_ids" "well_known" {}
resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

locals {
  msgraph_resource_access = {
    "User.Read.All" = {
      id   = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }
    "Policy.Read.All" = {
      id   = azuread_service_principal.msgraph.app_role_ids["Policy.Read.All"]
      type = "Role"
    }
    "AuditLog.Read.All" = {
      id   = azuread_service_principal.msgraph.app_role_ids["AuditLog.Read.All"]
      type = "Role"
    },
    "UserAuthenticationMethod.Read.All" = {
      id   = azuread_service_principal.msgraph.app_role_ids["UserAuthenticationMethod.Read.All"]
      type = "Role"
    },
    "Organization.Read.All" = {
      id   = azuread_service_principal.msgraph.app_role_ids["Organization.Read.All"]
      type = "Role"
    },
  }

  random = var.always_recreate_cloudbase_app ? "-${local.now_utc}" : ""
}

resource "azuread_application" "cloudbase_app" {
  display_name = "cloudbase-app-org${local.random}"

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    dynamic "resource_access" {
      for_each = local.msgraph_resource_access
      content {
        id   = resource_access.value.id
        type = resource_access.value.type
      }
    }
  }
}

resource "azuread_service_principal" "cloudbase_app_sp" {
  description = "Cloudbase App for directory connection created by Terraform"
  client_id   = azuread_application.cloudbase_app.client_id
}

resource "azuread_app_role_assignment" "admin_consent" {
  for_each            = local.msgraph_resource_access
  app_role_id         = each.value.id
  principal_object_id = azuread_service_principal.cloudbase_app_sp.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_directory_role" "security_reader" {
  display_name = "Security Reader"
}
resource "azuread_directory_role_assignment" "security_reader" {
  role_id             = azuread_directory_role.security_reader.template_id
  principal_object_id = azuread_service_principal.cloudbase_app_sp.object_id
}

resource "azuread_application_federated_identity_credential" "cloudbase_app_federated_credential_directory_scan" {
  application_id = azuread_application.cloudbase_app.id
  display_name   = "cloudbase-app-org-credential-for-directory-scan"

  issuer    = var.federated_identity_credential_directory_scan.issuer
  audiences = var.federated_identity_credential_directory_scan.audiences
  subject   = var.federated_identity_credential_directory_scan.subject
}

resource "azuread_application_federated_identity_credential" "cloudbase_app_federated_credential_security_scan" {
  application_id = azuread_application.cloudbase_app.id
  display_name   = "cloudbase-app-org-credential-for-security-scan"

  issuer    = var.federated_identity_credential_security_scan.issuer
  audiences = var.federated_identity_credential_security_scan.audiences
  subject   = var.federated_identity_credential_security_scan.subject
}
