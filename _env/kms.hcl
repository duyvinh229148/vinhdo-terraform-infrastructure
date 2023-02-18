locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  region         = local.env_vars.locals.region
}

terraform {
  source = "${path_relative_from_include()}//modules/kms"
}

inputs = {
  description              = "KMS Key for AWS EKS - Secret Encryption"
  deletion_windows_in_days = 30
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"

  aliases = [
    "alias/${local.region}-eks-secret"
  ]
}