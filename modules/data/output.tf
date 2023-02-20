output "sso_admin_role_arns" {
  value = data.aws_iam_roles.sso_admin.arns
}

output "sso_admin_role_eks_arns" {
  value = [
    for parts in [for arn in data.aws_iam_roles.sso_admin.arns : split("/", arn)] :
    format("%s/%s", parts[0], element(parts, length(parts) - 1))
  ]
}

output "sso_poweruser_role_eks_arns" {
  value = [
    for parts in [for arn in data.aws_iam_roles.sso_poweruser.arns : split("/", arn)] :
    format("%s/%s", parts[0], element(parts, length(parts) - 1))
  ]
}

output "sso_poweruser_role_arns" {
  value = data.aws_iam_roles.sso_poweruser.arns
}

output "sso_readonly_role_eks_arns" {
  value = [
    for parts in [for arn in data.aws_iam_roles.sso_readonly.arns : split("/", arn)] :
    format("%s/%s", parts[0], element(parts, length(parts) - 1))
  ]
}

output "sso_readonly_role_arns" {
  value = data.aws_iam_roles.sso_readonly.arns
}

output "kubernetes_deployer_role_eks_arns" {
  value = [
    for parts in [for arn in data.aws_iam_roles.kubernetes_deployer.arns : split("/", arn)] :
    format("%s/%s", parts[0], element(parts, length(parts) - 1))
  ]
}

output "kubernetes_deployer_role_arns" {
  value = data.aws_iam_roles.kubernetes_deployer.arns
}

output "aws_caller_identity_current_arn" {
  value = data.aws_caller_identity.current.arn
}