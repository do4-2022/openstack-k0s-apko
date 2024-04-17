resource "helm_release" "this" {
  name = "flux2"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"

  namespace = "flux-system"
  wait      = true

  ## Multi-tenancy lockdown
  set {
    name  = "multitenancy.enabled"
    value = "true"
  }
}

resource "helm_release" "sync" {
  name = "openstack-k0s-apko"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"

  namespace = "flux-system"
  wait      = true

  ## Git Repository
  set {
    name  = "gitRepository.spec.url"
    value = "https://github.com/do4-2022/openstack-k0s-apko"
  }

  set {
    name  = "gitRepository.spec.interval"
    value = "5m"
  }

  set {
    name  = "gitRepository.spec.ref.branch"
    value = "main"
  }

  ## Kustomization Repository
  set {
    name  = "kustomization.spec.interval"
    value = "5m"
  }

  set {
    name  = "kustomization.spec.prune"
    value = "true"
  }

  set {
    name  = "kustomization.spec.wait"
    value = "true"
  }

  set {
    name  = "kustomization.spec.path"
    value = "cluster"
  }

  set {
    name  = "kustomization.spec.serviceAccountName"
    value = "kustomize-controller"
  }

  depends_on = [helm_release.this]
}
