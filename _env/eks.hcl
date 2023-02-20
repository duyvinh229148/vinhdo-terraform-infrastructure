locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  region     = local.env_vars.locals.region
  user       = local.env_vars.locals.user

  cluster_name  = "my-${local.env}-cluster"
  iam_role_name = "tf-iam-role"
  role_arn      = "arn:aws:iam::${local.account_id}:role/${local.iam_role_name}"
}

dependency "vpc" {
  config_path = "//${get_repo_root()}/prod/vpc"

  mock_outputs = {
    vpc_id          = ""
    public_subnets  = [""]
    private_subnets = [""]
    subnet_ids      = [""]
    intra_subnets   = [""]
  }
}

generate "eks_providers" {
  path      = "eks_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  host                   = aws_eks_cluster.this[0].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this[0].id, "--role-arn", "${local.role_arn}", "--region", "${local.region}"]
  }
}
EOF
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
      #      preserve    = true
      most_recent = true

      #      timeouts = {
      #        create = "25m"
      #        delete = "10m"
      #      }
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
  iam_role_name             = local.iam_role_name
  aws_auth_roles            = [
    {
      rolearn  = "${local.role_arn}"
      username = "${local.role_arn}"
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