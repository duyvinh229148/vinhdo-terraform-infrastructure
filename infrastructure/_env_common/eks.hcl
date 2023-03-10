locals {
  account_vars             = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id           = local.account_vars.locals.aws_account_id
  terraform_execution_role = local.account_vars.locals.terraform_execution_role
  cluster_name             = local.account_vars.locals.cluster_name
  tf_role_name             = local.account_vars.locals.tf_role_name

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
}

dependency "vpc" {
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

  aws_region               = local.aws_region
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

  self_managed_node_group_defaults = {
    instance_type                          = "t3.medium"
    update_launch_template_default_version = true

    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]

    tags = {
      "karpenter.sh/discovery/${local.cluster_name}" = "${local.cluster_name}"
    }
    create_security_group = false
  }

  self_managed_node_groups = {
    karpenter = {
      name                     = "karpenter"
      create_autoscaling_group = false
      create_launch_template   = false
      create_schedule          = false
    }
  }

  fargate_profiles = {
    default = {
      name       = "default"
      subnet_ids = dependency.vpc.outputs.private_subnets
      selectors  = [
        {
          namespace = "default"
        }
      ]
    }
    kubesystem = {
      name       = "kube-system"
      subnet_ids = dependency.vpc.outputs.private_subnets
      selectors  = [
        {
          namespace = "kube-system"
        }
      ]
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