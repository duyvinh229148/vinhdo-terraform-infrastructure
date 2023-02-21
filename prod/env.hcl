locals {
  env        = "prod"
  account_id = "285574919501"
  region     = "ap-southeast-1"
  user       = "second-iam"

  cluster_name = "my-${local.env}-cluster"

  tf_role_name = "tf-eks-role"
  tf_role_arn  = "arn:aws:iam::${local.account_id}:role/${local.tf_role_name}"
}