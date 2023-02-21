locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  aws_region = local.env_vars.locals.aws_region

  tf_role_name             = local.env_vars.locals.tf_role_name
  terraform_execution_role = local.env_vars.locals.terraform_execution_role
}

dependency "eks-cluster" {
  config_path = "//${get_repo_root()}/prod/eks"

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
  source = "${path_relative_from_include()}/../modules/eks-networking-stack"
}

inputs = {
}