project_id     = "ai-infra-poc"
create_network = true
network_config = {
  network_name = "gke-ml-network"
  subnets = [{
    subnet_name           = "gke-ml-subnet"
    subnet_ip             = "10.100.0.0/16"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    description           = "GKE subnet"
  }]
  secondary_ranges = {
    "gke-ml-subnet" = [
      {
        range_name    = "us-central1-01-gke-01-pods-1"
        ip_cidr_range = "192.168.0.0/20"
      },
      {
        range_name    = "us-central1-01-gke-01-services-1"
        ip_cidr_range = "192.168.48.0/20"
      }
    ]
  }
}
repository_name = "gke-docker-repo"
gcs_config = {
  bucket_name = "gke-ml-bucket"
}
create_cluster    = true
private_cluster   = true  ## Default true. Use false for a public cluster
autopilot_cluster = false # false = standard cluster, true = autopilot cluster
gke_config = {
  cluster_regional                     = false
  cluster_name                         = "gke-ml-cluster"
  cluster_regional                     = false
  cluster_region                       = "us-central1"
  cluster_zones                        = ["us-central1-a"]
  ip_range_pods                        = "us-central1-01-gke-01-pods-1"
  ip_range_services                    = "us-central1-01-gke-01-services-1"
  master_ipv4_cidr_block               = "172.16.0.0/28"
  monitoring_enable_managed_prometheus = true
  master_authorized_networks = [{
    cidr_block   = "10.100.0.0/16"
    display_name = "VPC"
  }]
  #   NodeLocal DNSCache = enable
  ## Node configuration are ignored for autopilot clusters
  cpu_pools = [{
    name                   = "cpu-pool"
    machine_type           = "n2-standard-8"
    node_locations         = "us-central1-a"
    autoscaling            = true
    min_count              = 1
    max_count              = 2
    # local_ssd_count        = 1
    spot                   = false
    disk_size_gb           = 100
    disk_type              = "pd-standard"
    image_type             = "COS_CONTAINERD"
    # enable_gcfs            = false
    # enable_gvnic           = true # Recommended for better networking performance
    # logging_variant        = "DEFAULT"
    # auto_repair            = true
    # auto_upgrade           = true
    # create_service_account = true
    # preemptible            = false
    # initial_node_count     = 1
    # accelerator_count      = 0
    # gce_pd_csi_driver      = "DEFAULT"
    # local_nvme_ssd_count   = 1
    // ssd size =100
  }]
  enable_gpu = false
  gpu_pools = [{
    name                   = "gpu-pool"
    machine_type           = "g2-standard-8" # l4 Optimized for GPU workloads
    node_locations         = "us-central1-a" # Ensure availability for A2 VMs
    autoscaling            = true            # Enable autoscaling for GPU nodes
    min_count              = 1
    max_count              = 3
    # local_ssd_count        = 1
    spot                   = false
    disk_size_gb           = 100 # Consider larger disk for potential caching/data
    disk_type              = "pd-ssd"
    image_type             = "COS_CONTAINERD" #ubuntu (add comments) need to check exact image type for ubuntu
    enable_gcfs            = false
    enable_gvnic           = true # Recommended for better networking performance
    logging_variant        = "DEFAULT"
    auto_repair            = true
    auto_upgrade           = true
    create_service_account = true
    preemptible            = false
    initial_node_count     = 1
    accelerator_count      = 0
    accelerator_type       = "nvidia-l4" # (nvidia images - ubuntu) High-performance GPU for LLMs
    gpu_driver_version     = "DEFAULT"   # Use latest driver version for optimal performance
    local_nvme_ssd_count  = 1
    # ssd size = 100
  }]
  enable_tpu = false
  tpu_pools = [{
    name                   = "tpu-pool"
    machine_type           = "ct5lp-hightpu-8t" # Example: Powerful TPU v5e pod
    node_locations         = "us-central1-b"    # Choose a zone with TPU availability
    autoscaling            = true
    min_count              = 1
    max_count              = 3
    local_ssd_count        = 0
    spot                   = false
    disk_size_gb           = 100
    disk_type              = "pd-standard"
    image_type             = "COS_CONTAINERD" # Or "ubuntu_containerd" if preferred
    enable_gcfs            = false
    enable_gvnic           = true
    logging_variant        = "DEFAULT"
    auto_repair            = true
    auto_upgrade           = true
    create_service_account = true
    preemptible            = false
    initial_node_count     = 1
    accelerator_count      = 8                 # Matches the TPU cores in ct5lp-hightpu-8t
    accelerator_type       = "tpu-v5-lite-pod" # Corresponding TPU accelerator type
  }]
  ## pools config variables
  all_node_pools_oauth_scopes = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
  ]
  all_node_pools_labels = {
    "cloud.google.com/gke-profile" = "ray"
  }
  all_node_pools_metadata = {
    disable-legacy-endpoints = "true"
  }
  all_node_pools_tags = ["gke-node", "ai-on-gke"]
}