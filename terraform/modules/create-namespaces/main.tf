resource "kubernetes_namespace_v1" "flux-system" {
  metadata {
    name = "flux-system"
  }
}

resource "kubernetes_namespace_v1" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace_v1" "nginx" {
  metadata {
    name = "nginx"
  }
}
