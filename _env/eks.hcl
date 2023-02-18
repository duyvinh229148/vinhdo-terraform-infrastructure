locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env            = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  region         = local.env_vars.locals.region

  cluster_name = "${local.env}-${local.region}-cluster"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = ""
    public_subnets  = []
    private_subnets = []
  }
}

#dependency "mysql" {
#  config_path = "../mysql"
#}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=19.7.0"
}

inputs = {
  // EKS Cluster information
  // These should not be modified as they forces replacement of cluster
  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  aws_region = local.region
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = concat(dependency.vpc.outputs.public_subnets, dependency.vpc.outputs.private_subnets)


  env            = "${local.env}-${local.region}-cluster"
  basename       = "example-app-${local.env_name}"
  mysql_endpoint = dependency.mysql.outputs.endpoint
}