locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_account_id = local.env_vars.locals.aws_account_id
  region = local.env_vars.locals.region
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.19.0"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  name = "${local.region}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  // Private subnet gets /19 blocks (8190 addresses)
  private_subnets  = ["10.0.0.0/19", "10.0.32.0/19"] // 10.0.96.0/19
  // Public subnet gets /20 blocks (4094 addresses)
  public_subnets   = ["10.0.128.0/20", "10.0.144.0/20"] // 10.0.176.0/20
  // Database subnet gets /24 blocks (254 addresses)
  database_subnets = ["10.0.192.0/24", "10.0.193.0/24"] // 10.0.195.0/24

  // Enable DNS Support (required for EKS)
  enable_dns_support   = true
  enable_dns_hostnames = true

  // Enable single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  // Network ACL
  public_dedicated_network_acl   = true
  private_dedicated_network_acl  = true
  database_dedicated_network_acl = true

  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true

  #  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}