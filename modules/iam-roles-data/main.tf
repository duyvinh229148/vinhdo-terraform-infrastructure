data "aws_iam_roles" "sso_admin" {
  name_regex  = "AWSReservedSSO_AdministratorAccess.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "sso_poweruser" {
  name_regex  = "AWSReservedSSO_PowerUserAccess.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "sso_readonly" {
  name_regex  = "AWSReservedSSO_ReadOnlyAccess.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_roles" "kubernetes_deployer" {
  name_regex = "kubernetes-deployer-.*"
}

