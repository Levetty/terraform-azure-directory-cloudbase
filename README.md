# terraform-azure-directory-cloudbase

This Terraform module automates the setup of Cloudbase security roles and their assignments across Azure subscriptions. It provides a comprehensive solution for managing role-based access control (RBAC) in Azure environments.

## Features

- **Custom Role Definitions**: Creates and manages custom roles for Cloudbase security services

  - CSPM (Cloud Security Posture Management) role
  - CWPP (Cloud Workload Protection Platform) role
  - Auto Role Assignment role

- **Role Assignment Automation**: Automatically assigns roles to subscriptions using Azure Policy
  - Excludes specified subscriptions from automatic assignment
  - Supports both CSPM and CWPP role assignments
  - Handles role assignment remediation

## Prerequisites

- Azure CLI installed and configured
- Terraform v1.11 or later
- Azure subscription with appropriate permissions
- Management group access

## Usage

1. Set the required environment variables:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

2. Configure the module in your Terraform configuration:

```hcl
module "cloudbase" {
  source  = "Levetty/organization-cloudbase/azure"
  version = "0.0.1"

  tenant_id = "xxx" # required
  federated_identity_credential = {
    audiences = ["xxx"] # required
    issuer    = "xxx"  # required
    subject   = "xxx"  # required
  }

  // ...optional variables
}
```

3. Initialize and apply the Terraform configuration:

```bash
terraform init
terraform plan
terraform apply
```

## Input Variables

| Name                                        | Description                                                                                              | Type         | Default | Required |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------ | ------- | -------- |
| tenant_id                                   | The Azure Entra ID tenant ID                                                                             | string       | -       | yes      |
| federated_identity_credential               | Federated Identity Credential for establishing a connection between your Azure environment and Cloudbase. Expected structure: `{ audiences = list(string), issuer = string, subject = string }`. Example: `{ audiences = ["api://AzureADTokenExchange"], issuer = "https://sts.windows.net/{tenant_id}/", subject = "system-assigned-managed-identity" }` | object       | -       | yes      |
| always_recreate_cloudbase_app               | Controls whether to always recreate the cloudbase_app                                                    | bool         | false   | no       |
| excluded_subscription_ids                   | List of subscription IDs to exclude from automatic role assignment                                       | list(string) | []      | no       |
| enable_cnapp                                | Enable CNAPP functions                                                                                   | bool         | true    | no       |
| enable_autoassign                           | Enable automatic role assignment                                                                         | bool         | true    | no       |
| cspm_permissions                            | Specify the permissions for the CSPM role                                                                | object       | -       | no       |
| cwpp_permissions                            | Specify the permissions for the CWPP role                                                                | object       | -       | no       |
| auto_role_assignment_deployment_permissions | Specify the permissions for the auto role assignment deployment role                                     | object       | -       | no       |

## Outputs

The module provides the following outputs:

- `cloudbase_app_sp_object_id`: The Object ID of the Cloudbase application service principal

## Notes

- Role assignments are created at the subscription level
- The module uses Azure Policy for automatic role assignment
- Remediation tasks are created to ensure compliance
