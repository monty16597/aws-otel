locals {
  project_name     = var.project_name
  enivornment_name = var.environment_name
  name_prefix      = lower("${local.enivornment_name}-${local.project_name}")
}
