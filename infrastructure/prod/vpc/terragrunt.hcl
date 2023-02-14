locals {

}

include {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
    source = "github.com/terraform-aws-modules/terraform-aws-vpc//?ref=v3.19.0"
}

inputs = {
  name = "my-iac-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-southeast-1a", "ap-southeast-1b"]

  // subnets
  public_subnets = ["10.0.128.0/20", "10.0.144.0/20"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  database_subnets = ["10.0.192.0/24", "10.0.193.0/24"]

  // Enable single NAT Gateway
#  enable_nat_gateway = true
#  single_nat_gateway = true

}