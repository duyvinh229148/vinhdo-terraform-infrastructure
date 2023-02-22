locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id       = local.account_vars.locals.aws_account_id
  terraform_execution_role = local.account_vars.locals.terraform_execution_role

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region           = local.region_vars.locals.aws_region
}

terraform_version_constraint  = ">= 1.3.7"
terragrunt_version_constraint = ">= 0.43.0"

generate "versions" {
  path      = "override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.5"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }
}
EOF
}

remote_state {
  backend  = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "my-tf-state-${local.aws_account_id}-${local.aws_region}"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.aws_region}"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}