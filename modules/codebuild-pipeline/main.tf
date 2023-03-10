data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_roles" "kubernetes_deployer" {
  name_regex = "kubernetes_deployer-.*"
}

locals {
  aws_account_id         = coalesce(var.aws_account_id, data.aws_caller_identity.current.account_id)
  aws_region             = data.aws_region.current.name
  codebuild_project_name = coalesce(var.codebuild_project_name_override, "monorepo-${var.project_name}")
  iam_role_name          = coalesce(var.iam_role_name_override, "${var.project_name}-codebuild-role")
}



