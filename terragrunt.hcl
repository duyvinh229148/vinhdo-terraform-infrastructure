

locals {
  # Load the relevant env.hcl file based on where terragrunt was invoked. This works because find_in_parent_folders
  # always works at the context of the child configuration.
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_id = local.env_vars.locals.account_id
  region = local.env_vars.locals.region
  role_name = local.env_vars.locals.role_name
}

terraform_version_constraint = ">= 1.3.7"
terragrunt_version_constraint = ">= 0.43.0"
#iam_role = "arn:aws:iam::${local.account_id}:role/${local.role_name}"

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
    bucket = "my-tf-state-${local.account_id}-${local.region}"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region}"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}