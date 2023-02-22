locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  aws_region = local.env_vars.locals.aws_region
}

terraform {
  source = "${path_relative_from_include()}/..//modules/data"
}

inputs = {
}