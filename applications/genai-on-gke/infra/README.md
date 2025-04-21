- Permission required on the service account/useraccount to run the code
- basic APIs needs to be enabled


1. Backend Bucket
2. APIs enabled
3. Network Setup (multiple VPCs)
4. GKE Setup
5. Llama


```hcl
project_id = "ai-infra-poc"
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
    "ml-subnet" = [
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
}```