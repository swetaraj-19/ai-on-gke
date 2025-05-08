# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------
locals {
  network_name    = var.create_network ? module.vpc_network[0].network_name : var.network_config.network_name
  subnetwork_name = var.create_network ? module.vpc_network[0].subnets_names[0] : var.network_config.subnet_name
}

# -----------------------------------------------------------------------------
# Public GKE Standard Cluster
# -----------------------------------------------------------------------------
module "public-gke-standard-cluster" {
  count      = var.create_cluster && !var.private_cluster && !var.autopilot_cluster ? 1 : 0
  source     = "./modules/gke-standard-private-cluster"
  project_id = var.project_id

  ## network values
  network_name    = local.network_name
  subnetwork_name = local.subnetwork_name

  ## gke variables
  cluster_regional                     = var.gke_config.cluster_regional
  cluster_name                         = var.gke_config.cluster_name
  cluster_labels                       = var.gke_config.cluster_labels
  kubernetes_version                   = var.gke_config.kubernetes_version
  release_channel                      = var.gke_config.release_channel
  cluster_region                       = var.gke_config.cluster_region
  cluster_zones                        = var.gke_config.cluster_zones
  ip_range_pods                        = var.gke_config.ip_range_pods
  ip_range_services                    = var.gke_config.ip_range_services
  monitoring_enable_managed_prometheus = var.gke_config.monitoring_enable_managed_prometheus
  master_authorized_networks           = var.gke_config.master_authorized_networks
  gce_pd_csi_driver                    = var.gke_config.gce_pd_csi_driver
  gcs_fuse_csi_driver                  = var.gke_config.gcs_fuse_csi_driver
  local_nvme_ssd_count                 = var.gke_config.local_nvme_ssd_count

  ## pools config variables
  cpu_pools                   = var.gke_config.cpu_pools
  enable_gpu                  = var.gke_config.enable_gpu
  gpu_pools                   = var.gke_config.gpu_pools
  enable_tpu                  = var.gke_config.enable_tpu
  tpu_pools                   = var.gke_config.tpu_pools
  all_node_pools_oauth_scopes = var.gke_config.all_node_pools_oauth_scopes
  all_node_pools_labels       = var.gke_config.all_node_pools_labels
  all_node_pools_metadata     = var.gke_config.all_node_pools_metadata
  all_node_pools_tags         = var.gke_config.all_node_pools_tags

  depends_on = [
    google_project_service.project_services,
    module.vpc_network,
    module.firewall_rules,
    module.cloud-nat
  ]
}
# -----------------------------------------------------------------------------
# Public GKE Autopilot Cluster
# -----------------------------------------------------------------------------
## create public GKE autopilot
module "public-gke-autopilot-cluster" {
  count      = var.create_cluster && !var.private_cluster && var.autopilot_cluster ? 1 : 0
  source     = "../../../modules/gke-autopilot-public-cluster"
  project_id = var.project_id

  ## network values
  network_name    = local.network_name
  subnetwork_name = local.subnetwork_name

  ## gke variables
  cluster_regional           = var.gke_config.cluster_regional
  cluster_name               = var.gke_config.cluster_name
  cluster_labels             = var.gke_config.cluster_labels
  kubernetes_version         = var.gke_config.kubernetes_version
  release_channel            = var.gke_config.release_channel
  cluster_region             = var.gke_config.cluster_region
  cluster_zones              = var.gke_config.cluster_zones
  ip_range_pods              = var.gke_config.ip_range_pods
  ip_range_services          = var.gke_config.ip_range_services
  master_authorized_networks = var.gke_config.master_authorized_networks

  depends_on = [
    google_project_service.project_services,
    module.vpc_network,
    module.firewall_rules,
    module.cloud-nat
  ]
}
# -----------------------------------------------------------------------------
# Private GKE Standard Cluster
# -----------------------------------------------------------------------------
module "private-gke-standard-cluster" {
  count      = var.create_cluster && var.private_cluster && !var.autopilot_cluster ? 1 : 0
  source     = "../../../modules/gke-standard-private-cluster"
  project_id = var.project_id

  ## network values
  network_name    = local.network_name
  subnetwork_name = local.subnetwork_name

  ## gke variables
  cluster_regional                     = var.gke_config.cluster_regional
  cluster_name                         = var.gke_config.cluster_name
  cluster_labels                       = var.gke_config.cluster_labels
  kubernetes_version                   = var.gke_config.kubernetes_version
  release_channel                      = var.gke_config.release_channel
  cluster_region                       = var.gke_config.cluster_region
  cluster_zones                        = var.gke_config.cluster_zones
  ip_range_pods                        = var.gke_config.ip_range_pods
  ip_range_services                    = var.gke_config.ip_range_services
  monitoring_enable_managed_prometheus = var.gke_config.monitoring_enable_managed_prometheus
  master_authorized_networks           = var.gke_config.master_authorized_networks
  master_ipv4_cidr_block               = var.gke_config.master_ipv4_cidr_block
  ## pools config variables
  cpu_pools                   = var.gke_config.cpu_pools
  enable_gpu                  = var.gke_config.enable_gpu
  gpu_pools                   = var.gke_config.gpu_pools
  enable_tpu                  = var.gke_config.enable_tpu
  tpu_pools                   = var.gke_config.tpu_pools
  all_node_pools_oauth_scopes = var.gke_config.all_node_pools_oauth_scopes
  all_node_pools_labels       = var.gke_config.all_node_pools_labels
  all_node_pools_metadata     = var.gke_config.all_node_pools_metadata
  all_node_pools_tags         = var.gke_config.all_node_pools_tags

  depends_on = [
    google_project_service.project_services,
    module.vpc_network,
    module.firewall_rules,
    module.cloud-nat
  ]
}

# -----------------------------------------------------------------------------
# Private GKE Autopilot Cluster
# -----------------------------------------------------------------------------
module "private-gke-autopilot-cluster" {
  count      = var.create_cluster && var.private_cluster && var.autopilot_cluster ? 1 : 0
  source     = "../../../modules/gke-autopilot-private-cluster"
  project_id = var.project_id

  ## network values
  network_name    = local.network_name
  subnetwork_name = local.subnetwork_name

  ## gke variables
  cluster_regional           = var.gke_config.cluster_regional
  cluster_name               = var.gke_config.cluster_name
  cluster_labels             = var.gke_config.cluster_labels
  kubernetes_version         = var.gke_config.kubernetes_version
  release_channel            = var.gke_config.release_channel
  cluster_region             = var.gke_config.cluster_region
  cluster_zones              = var.gke_config.cluster_zones
  ip_range_pods              = var.gke_config.ip_range_pods
  ip_range_services          = var.gke_config.ip_range_services
  master_authorized_networks = var.gke_config.master_authorized_networks

  depends_on = [
    google_project_service.project_services,
    module.vpc_network,
    module.firewall_rules,
    module.cloud-nat
  ]
}

