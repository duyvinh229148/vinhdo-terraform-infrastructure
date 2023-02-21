data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_id
}

data "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = data.aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}
