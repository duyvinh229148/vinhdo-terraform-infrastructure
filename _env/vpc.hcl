locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_id = local.env_vars.locals.account_id
  aws_region = local.env_vars.locals.aws_region
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.19.0"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  # VPC Basic Details
  name = "${local.region}-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  intra_subnets    = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]

  # Database Subnets
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  database_subnets                   = ["10.0.151.0/24", "10.0.152.0/24"]

  // Enable DNS Support (required for EKS)
  enable_dns_support   = true
  enable_dns_hostnames = true

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = true
  single_nat_gateway = true

  // Network ACL
  public_dedicated_network_acl   = true
  private_dedicated_network_acl  = true
  database_dedicated_network_acl = true

  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true

  public_subnet_tags = {
    Type = "public-subnets"
  }

  private_subnet_tags = {
    Type = "private-subnets"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "eks-vpc"
  }
}