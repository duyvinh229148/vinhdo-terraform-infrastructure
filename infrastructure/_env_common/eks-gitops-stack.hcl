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
    cluster_id                         = ""
    cluster_endpoint                   = ""
    cluster_certificate_authority_data = ""
  }
}

generate "eks_providers" {
  path      = "eks_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  host                   = "${dependency.eks_cluster.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks_cluster.outputs.cluster_certificate_authority_data}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks_cluster.outputs.cluster_id}", "--role-arn", "${local.terraform_execution_role}", "--region", "${local.aws_region}"]
  }
}
provider "helm" {
  kubernetes {
    host                   = "${dependency.eks_cluster.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.eks_cluster.outputs.cluster_certificate_authority_data}")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", "${dependency.eks_cluster.outputs.cluster_id}", "--role-arn", "${local.terraform_execution_role}", "--region", "${local.aws_region}"]
    }
  }
}
provider "kubectl" {
  apply_retry_count      = 5
  load_config_file       = false
  host                   = "${dependency.eks_cluster.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks_cluster.outputs.cluster_certificate_authority_data}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks_cluster.outputs.cluster_id}", "--role-arn", "${local.terraform_execution_role}", "--region", "${local.aws_region}"]
  }
}
provider "sops" {}
EOF
}

terraform {
  source = "${path_relative_from_include()}/..//modules/eks-gitops-stack"
}

inputs = {
  cluster_id = dependency.eks_cluster.outputs.cluster_id
  aws_region = local.aws_region

  #  ArgoCD
  argocd_external_host                   = "argocd.dev.your.rentals"
  argocd_external_host_tls_secret_name   = "your-rentals-tls"
  argocd_dex_google_auth_enabled         = true
  argocd_dex_google_auth_client_id       = local.argocd_secrets.clientID
  argocd_dex_google_auth_client_secret   = local.argocd_secrets.clientSecret
  argocd_dex_google_auth_allowed_domains = [
    "your.rentals"
  ]
}