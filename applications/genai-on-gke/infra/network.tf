module "vpc_network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "8.0.0"
  for_each                               = var.create_network ? var.network_configs.vpc : {}
  project_id                             = each.value.project_id
  network_name                           = each.value.name
  routing_mode                           = each.value.routing_mode
  delete_default_internet_gateway_routes = each.value.delete_default_internet_gateway_routes
  subnets                                = each.value.subnets
  secondary_ranges                       = each.value.secondary_ranges
}


module "firewall_rules" {
  source        = "terraform-google-modules/network/google//modules/firewall-rules"
  version       = "9.1.0"
  for_each      = var.network_configs.vpc
  project_id    = each.value.project_id
  network_name  = module.vpc_network[each.key].network_name
  egress_rules  = each.value.firewall_rules.egress
  ingress_rules = each.value.firewall_rules.ingress
}

# Create a local map filtering the VPCs based on the condition
locals {
  vpc_for_nat = {
    for k, v in var.network_configs.vpc : k => v
    if var.create_network && var.private_cluster && var.network_configs.vpc != null
  }
}

## Configure cloud NAT for private GKE
module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "5.0.0"
  for_each      = local.vpc_for_nat
  region        = each.value.subnets[0].subnet_region
  project_id    = var.project_id
  create_router = true
  router        = "${module.vpc_network[each.key].network_name}-router"
  name          = "cloud-nat-${module.vpc_network[each.key].network_name}-router"
  network       = module.vpc_network[each.key].network_name
}