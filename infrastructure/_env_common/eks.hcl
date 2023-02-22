locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  aws_region = local.env_vars.locals.aws_region
  user       = local.env_vars.locals.user

  cluster_name             = local.env_vars.locals.cluster_name
  tf_role_name             = local.env_vars.locals.tf_role_name
  terraform_execution_role = local.env_vars.locals.terraform_execution_role
}

dependency "vpc" {
  #  config_path = "//${get_repo_root()}/prod/vpc"
  config_path = "${get_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id          = ""
    public_subnets  = [""]
    private_subnets = [""]
    subnet_ids      = [""]
    intra_subnets   = [""]
  }
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=19.7.0"
}

inputs = {
  cluster_name                   = local.cluster_name
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true

      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most-recent = true
    }
  }

  aws_region               = local.region
  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets
  control_plane_subnet_ids = dependency.vpc.outputs.intra_subnets

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  iam_role_name             = local.tf_role_name
  aws_auth_roles            = [
    {
      rolearn  = "${local.terraform_execution_role}"
      username = "${local.tf_role_name}"
      groups   = ["system:masters"]
    }
  ]

  fargate_profiles = {
    default = {
      name       = "default"
      subnet_ids = dependency.vpc.outputs.private_subnets
      selectors  = [
        {
          namespace = "kube-system"
          #          labels    = {
          #            k8s-app = "kube-dns"
          #          }
        },
        {
          namespace = "default"
        }
      ]

      tags = {
        Owner = "test"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
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