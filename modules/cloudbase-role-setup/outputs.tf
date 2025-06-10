output "cspm_role_definition_id" {
  value = local.cspm_role_def_id
}

output "cwpp_role_definition_id" {
  value = var.enable_cnapp ? local.cwpp_role_def_id : ""
}
