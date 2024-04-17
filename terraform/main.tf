resource "random_id" "this" {
  byte_length = 8
}

module "bootstrap" {
  source = "./modules/bootstrap"

  public_key_pair_name = "k0s-${random_id.this.hex}"
  public_key_pair_path = var.public_key_pair_path
}

module "network" {
  source = "./modules/network"

  name                = "k0s.${random_id.this.hex}"
  cidr                = var.network_cidr
  external_network_id = var.network_external_id
  dns_servers         = var.network_dns_servers

  depends_on = [module.bootstrap]
}

module "security_groups" {
  source = "./modules/security-groups"

  cidr = var.network_cidr
}

module "control_plane" {
  source = "./modules/instance"
  count  = var.control_plane_number

  name      = "k0s.control-plane.${count.index}.${random_id.this.hex}"
  image_id  = var.control_plane_image_id
  flavor_id = var.control_plane_flavor_id

  public_key_pair = module.bootstrap.public_key_pair_name
  ssh_login_name  = var.ssh_login_name

  security_groups = [
    module.security_groups.ssh_name,
    module.security_groups.control_plane_api_name,
    module.security_groups.controller_name
  ]

  network = {
    name             = module.network.name
    floating_ip_pool = var.network_floating_ip_pool
  }

  depends_on = [module.bootstrap, module.network, module.security_groups]
}

module "worker" {
  source = "./modules/instance"
  count  = var.worker_number

  name      = "k0s.worker.${count.index}.${random_id.this.hex}"
  image_id  = var.worker_image_id
  flavor_id = var.worker_flavor_id

  public_key_pair = module.bootstrap.public_key_pair_name
  ssh_login_name  = var.ssh_login_name

  security_groups = [
    module.security_groups.ssh_name,
    module.security_groups.worker_name,
    module.security_groups.http_name
  ]

  network = {
    name             = module.network.name
    floating_ip_pool = var.network_floating_ip_pool
  }

  depends_on = [module.bootstrap, module.network, module.security_groups]
}

module "k0s-cluster" {
  source = "./modules/k0s-cluster"

  ssh_login_name = var.ssh_login_name
  hosts = concat(
    [for instance in module.control_plane : {
      role                = "controller"
      private_ip_address  = instance.access_ip_v4
      floating_ip_address = instance.floating_ip_address
    }],
    [for instance in module.worker : {
      role                = "worker"
      private_ip_address  = instance.access_ip_v4
      floating_ip_address = instance.floating_ip_address
    }]
  )

  depends_on = [module.bootstrap, module.network, module.security_groups, module.control_plane, module.worker]
}

module "os-cloud-secret" {
  source = "./modules/os-cloud-secret"

  name = "k0s.${random_id.this.hex}"

  openstack_auth_url         = var.openstack_auth_url
  cluster_config             = module.k0s-cluster.kubeconfig
  network_external_id        = var.network_external_id
  network_internal_subnet_id = module.network.subnet_id
}

locals {
  kube_config = yamldecode(module.k0s-cluster.kubeconfig)
}

module "create-namespaces" {
  source = "./modules/create-namespaces"

  cluster_config_endpoint               = local.kube_config.clusters[0].cluster.server
  cluster_config_cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  cluster_config_client_certificate     = base64decode(local.kube_config.users[0].user.client-certificate-data)
  cluster_config_client_key             = base64decode(local.kube_config.users[0].user.client-key-data)
}

module "flux-bootstrap" {
  source = "./modules/flux-bootstrap"

  cluster_config_endpoint               = local.kube_config.clusters[0].cluster.server
  cluster_config_cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  cluster_config_client_certificate     = base64decode(local.kube_config.users[0].user.client-certificate-data)
  cluster_config_client_key             = base64decode(local.kube_config.users[0].user.client-key-data)
}
