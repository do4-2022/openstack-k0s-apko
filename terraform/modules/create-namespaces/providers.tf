provider "kubernetes" {
  host                   = var.cluster_config_endpoint
  client_certificate     = var.cluster_config_client_certificate
  client_key             = var.cluster_config_client_key
  cluster_ca_certificate = var.cluster_config_cluster_ca_certificate
}
