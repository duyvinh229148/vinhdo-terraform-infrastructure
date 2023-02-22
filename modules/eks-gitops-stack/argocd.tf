resource "helm_release" "argocd" {
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "argo-cd"
  version          = "2.6.2"
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
}