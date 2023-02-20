locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env        = local.env_vars.locals.env
  account_id = local.env_vars.locals.account_id
  region     = local.env_vars.locals.region
  user       = local.env_vars.locals.user

  cluster_name             = "${local.env}-${local.region}-cluster"
  terraform_execution_role = "arn:aws:iam::${local.account_id}:role/prod-ap-southeast-1-cluster-cluster-20230218075044698100000004"
}

dependency "vpc" {
  config_path = "//${get_repo_root()}/prod/vpc"

  mock_outputs = {
    vpc_id          = ""
    public_subnets  = []
    private_subnets = []
    control_plane_subnet_ids = ["1.1.1.1"]
    subnet_ids = ["1.1.1.1"]
    intra_subnets = []
  }
}

dependency "iam_roles_data" {
  config_path = "//${get_repo_root()}/prod/iam-roles-data"
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
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this[0].id, "--role-arn", "${local.terraform_execution_role}", "--region", "${local.region}"]
  }
}
EOF
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

  # Self managed node groups will not automatically create the aws-auth configmap so we need to
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  #  aws_auth_roles            = concat(
  #    [
  #      for arn in dependency.iam_roles_data.outputs.sso_admin_role_eks_arns : {
  #      rolearn  = "${arn}"
  #      username = "aws:{{AccountID}}:administrator:{{SessionName}}"
  #      groups   = ["system:masters"]
  #    }
  #    ],
  #    [
  #      for arn in dependency.iam_roles_data.outputs.sso_poweruser_role_eks_arns : {
  #      rolearn  = "${arn}"
  #      username = "aws:{{AccountID}}:poweruser:{{SessionName}}"
  #      groups   = ["system:masters"]
  #    }
  #    ],
  #  )

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/${local.user}"
      username = "${local.user}"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    "${local.account_id}"
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
    aws-ebs-csi-driver = {
      most-recent = true
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