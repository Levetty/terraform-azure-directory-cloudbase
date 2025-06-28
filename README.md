# terraform-azure-directory-cloudbase

This Terraform module enables integration between your Azure environment and Cloudbase security service. It automates the necessary setup for Cloudbase to connect to and monitor your Azure subscriptions, including creating service principals, security groups, and defining security roles.

## Architecture Overview

The module consists of two main components:

1. **Cloudbase App**: Creates an Azure AD application, service principal, and security group that Cloudbase uses to authenticate and access your Azure resources
2. **Role Setup**: Defines custom security roles with appropriate permissions for Cloudbase to perform its security functions

## Features

- **Azure AD Application and Security Group**

  - Creates a dedicated application that Cloudbase uses to connect to your Azure environment
  - Creates a security group for managing role assignments
  - Service principal is automatically added as a member of the security group
  - Configures federated identity credentials for secure, passwordless authentication
  - Assigns necessary Microsoft Graph API permissions for directory and audit log access
  - Assigns Security Reader directory role to the service principal

- **Custom Security Roles for Cloudbase**

  - **CSPM (Cloud Security Posture Management)**: Read-only permissions with data actions support for comprehensive security assessment
  - **CWPP (Cloud Workload Protection Platform)**: Additional permissions for workload protection (conditional on `enable_cnapp`)
  - **Management Group Reader**: Built-in role for reading management group structure
  - Roles are assigned to the security group, not directly to the service principal
  - Automatic handling of Azure's management group limitations with data actions

## Prerequisites

- Azure CLI installed and configured
- Terraform v1.11 or later
- Azure subscription with appropriate permissions
- Management group access for role assignments
- Azure AD permissions to create applications and assign directory roles
- **Azure Subscription ID**: The azurerm provider needs a subscription ID, which can be provided in one of the following ways (in order of precedence):
  1. Set the `subscription_id` variable in your Terraform configuration
  2. Export the ARM_SUBSCRIPTION_ID environment variable:
     ```bash
     export ARM_SUBSCRIPTION_ID="your-subscription-id"
     ```
  3. Export the AZURE_SUBSCRIPTION_ID environment variable:
     ```bash
     export AZURE_SUBSCRIPTION_ID="your-subscription-id"
     ```
  4. Use the current Azure CLI subscription (set with `az account set --subscription`)

## Usage

### Basic Example

```hcl
module "cloudbase" {
  source = "Levetty/directory-cloudbase/azure"

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

### Advanced Example

```hcl
module "cloudbase" {
  source = "Levetty/directory-cloudbase/azure"

  directory_id = "your-tenant-id"

  # Directory scan credential for Azure AD/Entra ID access
  federated_identity_credential_directory_scan = {
    audiences = ["<audience>"]
    issuer    = "<issuer>"
    subject   = "<subject>"
  }

  # Security scan credential for Azure resource access
  federated_identity_credential_security_scan = {
    audiences = ["<audience>"]
    issuer    = "<issuer>"
    subject   = "<subject>"
  }

  # Optional: Specify subscription ID for provider
  subscription_id = "your-subscription-id"

  # Disable CWPP functionality
  enable_cnapp = false

  # Use existing Cloudbase app (useful for development/testing)
  always_recreate_cloudbase_app = false
}
```

## Input Variables

| Name                                           | Description                                                                                                                                                                                  | Type                                                                      | Default      | Required |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------ | -------- |
| `directory_id`                                 | The Azure Entra ID (formerly Azure AD) tenant/directory ID where Cloudbase resources will be created                                                                                         | `string`                                                                  | -            | yes      |
| `federated_identity_credential_directory_scan` | Federated Identity Credential for establishing secure connection between Azure and Cloudbase. These values are provided by Cloudbase during onboarding                                       | `object({ audiences = list(string), issuer = string, subject = string })` | -            | yes      |
| `federated_identity_credential_security_scan`  | Federated Identity Credential for establishing a connection between your Azure environment and Cloudbase. Please provide the values supplied by Cloudbase. For security scan                 | `object({ audiences = list(string), issuer = string, subject = string })` | -            | yes      |
| `subscription_id`                              | The Azure subscription ID to be used by the azurerm provider. If not provided, it will be automatically resolved from environment variables or Azure CLI. See [Prerequisites](#prerequisites) for details | `string`                                                                  | `""`         | no       |
| `always_recreate_cloudbase_app`                | Controls whether to force recreation of the Cloudbase application. Set to true to create a new app with unique name on every apply. Set to false when using remote Terraform state           | `bool`                                                                    | `false`      | no       |
| `enable_cnapp`                                 | Enable Cloud Native Application Protection Platform (CNAPP) functionality. When true, creates both CSPM and CWPP roles for comprehensive cloud security                                      | `bool`                                                                    | `true`       | no       |
| `directory_connection_permissions`             | Built-in roles for directory connection (Management Group Reader)                                                                                                                            | `object`                                                                  | See defaults | no       |
| `cspm_permissions`                             | Permissions for Cloud Security Posture Management (CSPM) role. CSPM continuously monitors cloud resources for security misconfigurations and compliance violations                           | `object`                                                                  | See defaults | no       |
| `cwpp_permissions`                             | Permissions for Cloud Workload Protection Platform (CWPP) role. CWPP provides runtime protection for cloud workloads including VMs, containers, and serverless functions                     | `object`                                                                  | See defaults | no       |

## Outputs

| Name                           | Description                                         |
| ------------------------------ | --------------------------------------------------- |
| `cloudbase_app_application_id` | The Application ID (Client ID) of the Cloudbase App |
| `cloudbase_group_object_id`    | The object ID of the Cloudbase security group       |
| `directory_id`                 | The Azure Entra ID tenant/directory ID              |
| `cspm_role_def_name`           | The name of the CSPM role definition                |
| `cwpp_role_def_name`           | The name of the CWPP role definition                |

## How It Works

1. **Application Creation**: The module creates an Azure AD application and service principal that Cloudbase will use to authenticate
2. **Security Group Creation**: A security group is created to manage role assignments, with the service principal as a member
3. **Role Definition**: Custom roles are created with the permissions required for Cloudbase to perform its security monitoring functions
4. **Role Assignment**: Roles (including Management Group Reader) are assigned to the security group at the management group level
5. **Data Actions Handling**: For roles with data actions, the module automatically handles Azure's limitations by updating the role definition after assignment

## Known Limitations

- Directory roles (like Security Reader) cannot be assigned to groups without Azure AD Premium licenses
- Roles with data actions cannot be initially assigned at the management group level (handled automatically by the module)
- The security group requires manual management of additional members if needed
- Management Group Reader role assignment requires the role definition ID to match the actual Azure built-in role
