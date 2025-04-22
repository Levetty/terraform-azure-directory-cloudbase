###############################################################################
# Required
###############################################################################
variable "federated_identity_credential" {
  type = object({
    audiences = list(string)
    issuer    = string
    subject   = string
  })
  description = "(required) Federated Identity Credential for establishing a connection between your Azure environment and Cloudbase. Please provide the values supplied by Cloudbase."
}

variable "always_recreate_cloudbase_app" {
  description = "(optional) Controls whether to always recreate the cloudbase_app. When set to true, the application will be recreated (with a new name) even if it already exists. Set to false if you are using remote Terraform state."
  type        = bool
}
