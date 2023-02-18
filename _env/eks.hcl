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

dependency "iam_roles_data" {
  config_path = "/home/ubuntu/Documents/vinhdo/vinhdo-terraform-infrastructure/prod/iam-roles-data"
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

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles = concat(
    [
      for arn in dependency.iam_roles_data.outputs.sso_admin_role_eks_arns : {
        rolearn  = "${arn}"
        username = "aws:{{AccountID}}:administrator:{{SessionName}}"
        groups   = ["system:masters"]
      }
    ],
    [
      for arn in dependency.iam_roles_data.outputs.sso_poweruser_role_eks_arns : {
        rolearn  = "${arn}"
        username = "aws:{{AccountID}}:poweruser:{{SessionName}}"
        groups   = ["system:masters"]
      }
    ],
  )

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