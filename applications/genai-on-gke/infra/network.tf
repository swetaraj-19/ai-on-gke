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