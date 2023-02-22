locals {
  aws_account_id = "285574919501"

  env  = "prod"
  #  account_id = "285574919501"
  #  region     = "ap-southeast-1"
  user = "second-iam"

  cluster_name = "my-${local.env}-cluster"

  tf_role_name             = "tf-eks-role"
  terraform_execution_role = "arn:aws:iam::${local.aws_account_id}:role/${local.tf_role_name}"
}