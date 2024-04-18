resource "helm_release" "this" {
  name = "flux2"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.12.4"

  namespace = "flux-system"
  wait      = true

  ## Multi-tenancy lockdown
  set {
    name  = "multitenancy.enabled"
    value = "true"
  }
}
