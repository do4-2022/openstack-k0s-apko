resource "kubernetes_namespace_v1" "flux-system" {
  metadata {
    name = "flux-system"
  }
}
