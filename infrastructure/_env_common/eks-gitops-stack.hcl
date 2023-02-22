locals {
  account_vars             = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id           = local.account_vars.locals.aws_account_id
  terraform_execution_role = local.account_vars.locals.terraform_execution_role
  cluster_name             = local.account_vars.locals.cluster_name
  tf_role_name             = local.account_vars.locals.tf_role_name

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
}

dependency "eks_cluster" {
  config_path = "${get_terragrunt_dir()}/../eks"

  mock_outputs = {
    cluster_id = ""
  }
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/..//modules/eks-gitops-stack"
}

inputs = {
  cluster_id = dependency.eks_cluster.outputs.cluster_id
  aws_region = local.aws_region

  #  ArgoCD
  #  argocd_external_host                   = "argocd.dev.your.rentals"
  #  argocd_external_host_tls_secret_name   = "your-rentals-tls"
  #  argocd_dex_google_auth_enabled         = true
  #  argocd_dex_google_auth_client_id       = local.argocd_secrets.clientID
  #  argocd_dex_google_auth_client_secret   = local.argocd_secrets.clientSecret
  #  argocd_dex_google_auth_allowed_domains = [
  #    "your.rentals"
  #  ]
}