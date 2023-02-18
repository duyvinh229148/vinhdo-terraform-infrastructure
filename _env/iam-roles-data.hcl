locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  region = local.env_vars.locals.region
}

terraform {
  source = "${path_relative_from_include()}/../modules/iam-roles-data"
}

inputs = {
}