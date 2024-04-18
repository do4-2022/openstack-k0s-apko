variable "name" {
  description = "The name of the Helm release"
  type        = string
}

variable "namespace" {
  description = "The namespace to install the Helm release"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account to use"
  type        = string
}

variable "path" {
  description = "The path to the kustomization files"
  type        = string
}

variable "cluster_config_endpoint" {
  description = "The Kubernetes API server endpoint"
  type        = string
}

variable "cluster_config_client_certificate" {
  description = "The client certificate for authenticating to the Kubernetes API server"
  type        = string
}

variable "cluster_config_client_key" {
  description = "The client key for authenticating to the Kubernetes API server"
  type        = string
}

variable "cluster_config_cluster_ca_certificate" {
  description = "The cluster CA certificate for authenticating to the Kubernetes API server"
  type        = string
}
