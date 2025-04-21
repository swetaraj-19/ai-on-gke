module "vpc_network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "8.0.0"
  count                                  = var.create_network ? 1 : 0
  project_id                             = var.project_id
  network_name                           = var.network_config.network_name
  routing_mode                           = var.network_config.routing_mode
  delete_default_internet_gateway_routes = var.network_config.delete_default_internet_gateway_routes
  subnets                                = var.network_config.subnets
  secondary_ranges                       = var.network_config.secondary_ranges
}


module "firewall_rules" {
  source        = "terraform-google-modules/network/google//modules/firewall-rules"
  version       = "9.1.0"
  project_id    = var.project_id
  network_name  = module.vpc_network[0].network_name
  egress_rules  = var.network_config.firewall_rules.egress
  ingress_rules = var.network_config.firewall_rules.ingress
}

## Configure cloud NAT for private GKE
module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "5.0.0"
  region        = var.region
  project_id    = var.project_id
  create_router = true
  router        = "${module.vpc_network[0].network_name}-router"
  name          = "cloud-nat-${module.vpc_network[0].network_name}-router"
  network       = module.vpc_network[0].network_name
}
