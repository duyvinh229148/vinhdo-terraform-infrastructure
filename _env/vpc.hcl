locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_account_id = local.env_vars.locals.aws_account_id
  aws_region = local.env_vars.locals.aws_region
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.19.0"
}

# Indicate the input values to use for the variables of the module.
inputs = {
  name = "${local.aws_region}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.aws_region}a", "${local.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  // Enable single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  #  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}