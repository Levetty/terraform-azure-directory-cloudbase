# terraform-azure-directory-cloudbase

This Terraform module enables integration between your Azure environment and Cloudbase security service. It automates the necessary setup for Cloudbase to connect to and monitor your Azure subscriptions, including creating service principals, defining security roles, and configuring automated role assignments.

## Architecture Overview

The module consists of three main components:

1. **Cloudbase App**: Creates an Azure AD application and service principal that Cloudbase uses to authenticate and access your Azure resources
2. **Role Setup**: Defines custom security roles with appropriate permissions for Cloudbase to perform its security functions
3. **Role Automation**: Implements Azure Policy for automatic role assignment to new subscriptions

## Features

- **Azure AD Application for Cloudbase**

  - Creates a dedicated application that Cloudbase uses to connect to your Azure environment
  - Configures federated identity credentials for secure, passwordless authentication
  - Assigns necessary Microsoft Graph API permissions for directory and audit log access

- **Custom Security Roles for Cloudbase**

  - **CSPM (Cloud Security Posture Management)**: Read-only permissions that allow Cloudbase to assess your security posture
  - **CWPP (Cloud Workload Protection Platform)**: Additional permissions for Cloudbase to provide workload protection (conditional on `enable_cnapp`)

- **Automated Role Assignment**
  - Automatically grants Cloudbase access to new subscriptions via Azure Policy
  - Supports exclusion of sensitive subscriptions from Cloudbase monitoring
  - Creates remediation tasks to ensure continuous compliance

## Prerequisites

- Azure CLI installed and configured
- Terraform v1.11 or later
- Azure subscription with appropriate permissions
- Management group access (for policy assignment)

## Usage

### Basic Example

```hcl
module "cloudbase" {
  source = "Levetty/organization-cloudabse/azure"

  directory_id = "your-tenant-id"

  # Directory scan credential for Azure AD/Entra ID access
  federated_identity_credential_directory_scan = {
    issuer    = "<issuer>"
    subject   = "<subject>"
    audiences = ["<audience>"]
  }

  # Security scan credential for Azure resource access
  federated_identity_credential_security_scan = {
    issuer    = "<issuer>"
    subject   = "<subject>"
    audiences = ["<audience>"]
  }
}
```

### Advanced Example with Exclusions

```hcl
module "cloudbase" {
  source = "Levetty/organization-cloudabse/azure"

  directory_id = "your-tenant-id"

  # Directory scan credential for Azure AD/Entra ID access
  federated_identity_credential_directory_scan = {
    audiences = ["<audience>"]
    issuer    = "<issuer>"
    subject   = "<subject>"
  }

  # Security scan credential for Azure resource access
  federated_identity_credential_security_scan = {
    audiences = ["api://AzureADTokenExchange"]
    issuer    = "https://cloudbase.example.com"
    subject   = "cloudbase-security-scan"
  }

  # Exclude specific subscriptions from role assignment
  excluded_subscription_ids = [
    "subscription-id-1",
    "subscription-id-2"
  ]

  # Disable CWPP functionality
  enable_cnapp = false

  # Disable automatic role assignment for new subscriptions
  enable_autoassign = false
  always_recreate_cloudbase_app = false
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `directory_id` | The Azure Entra ID tenant/directory ID | `string` | - | yes |
| `federated_identity_credential_directory_scan` | Federated identity credential for Cloudbase directory scan access | `object({ audiences = list(string), issuer = string, subject = string })` | - | yes |
| `federated_identity_credential_security_scan` | Federated identity credential for Cloudbase security scan access | `object({ audiences = list(string), issuer = string, subject = string })` | - | yes |
| `always_recreate_cloudbase_app` | Always recreate the Cloudbase app (useful for testing) | `bool` | `false` | no |
| `excluded_subscription_ids` | List of subscription IDs to exclude from role assignments | `list(string)` | `[]` | no |
| `enable_cnapp` | Enable CNAPP functions (controls CWPP role creation) | `bool` | `true` | no |
| `enable_autoassign` | Enable automatic role assignment for new subscriptions | `bool` | `true` | no |
| `directory_connection_permissions` | Built-in roles for directory connection | `object` | See defaults | no |
| `cspm_permissions` | Custom permissions for CSPM role | `object` | See defaults | no |
| `cwpp_permissions` | Custom permissions for CWPP role | `object` | See defaults | no |
| `auto_role_assignment_deployment_permissions` | Permissions for policy deployment role | `object` | See defaults | no |

## Outputs

| Name                           | Description                                         |
| ------------------------------ | --------------------------------------------------- |
| `cloudbase_app_application_id` | The Application ID (Client ID) of the Cloudbase App |
| `directory_id`                 | The Azure Entra ID tenant/directory ID              |

## How It Works

1. **Application Creation**: The module creates an Azure AD application that Cloudbase will use to authenticate with your Azure environment
2. **Role Definition**: Custom roles are created with the minimum permissions required for Cloudbase to perform its security monitoring functions
3. **Initial Assignment**: Cloudbase is granted access to all enabled subscriptions (excluding specified ones)
4. **Policy Setup** (if `enable_autoassign = true`): Azure Policy ensures Cloudbase automatically gets access to new subscriptions
