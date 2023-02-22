locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  aws_region = local.env_vars.locals.aws_region

  tf_role_name             = local.env_vars.locals.tf_role_name
  terraform_execution_role = local.env_vars.locals.terraform_execution_role
}

dependency "eks_cluster" {
  config_path = "${get_terragrunt_dir()}/../eks"

  mock_outputs = {
    cluster_id = ""
  }
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/..//modules/eks-networking-stack"
}

inputs = {
}