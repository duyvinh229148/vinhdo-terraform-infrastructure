locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  region     = local.env_vars.locals.region

  cluster_name = "${local.env}-${local.region}-cluster"
}

dependency "vpc" {
  #  config_path = "${path_relative_to_include()}/../vpc"
  config_path = "/home/ubuntu/Documents/vinhdo/vinhdo-terraform-infrastructure/prod/vpc"

  mock_outputs = {
    vpc_id          = ""
    public_subnets  = []
    private_subnets = []
  }
}

dependency "kms" {
  #  config_path = "${path_relative_to_include()}/../kms"
  config_path = "/home/ubuntu/Documents/vinhdo/vinhdo-terraform-infrastructure/prod/kms"

  mock_outputs = {
    this_key_arn = ""
  }
}

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

  cluster_encryption_config = [
    {
      provider_key_arn = dependency.kms.outputs.this_key_arn
      resources        = ["secrets"]
    }
  ]

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  fargate_profiles = {
    karpenter = {
      name       = "karpenter"
      subnet_ids = dependency.vpc.outputs.private_subnets
      selectors  = [
        {
          namespace = "karpenter"
        }
      ]
    }
  }
}