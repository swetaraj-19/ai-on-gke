# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "region" {
  type        = string
  description = "GCP project region or zone"
  default     = "us-central1"
}

## Required APIs to be enabled
variable "api_services" {
  description = "Service APIs to enable."
  type        = list(string)
  default     = []
}

variable "service_config" {
  description = "Configure service API activation."
  type = object({
    disable_on_destroy         = bool
    disable_dependent_services = bool
  })
  default = {
    disable_on_destroy         = false
    disable_dependent_services = false
  }
}

## Network variables

variable "create_network" {
  type = bool
}

variable "network_config" {
  description = "Network Configuration"
  type = object({
    network_name                           = string
    routing_mode                           = optional(string, "GLOBAL")
    delete_default_internet_gateway_routes = optional(bool, true)
    reserve_static_ip                      = optional(bool, false)
    subnets = list(object(
      {
        subnet_name                      = string,
        subnet_ip                        = string,
        subnet_region                    = string,
        subnet_private_access            = string,
        subnet_private_ipv6_access       = optional(string)
        subnet_flow_logs                 = optional(string)
        subnet_flow_logs_interval        = optional(string)
        subnet_flow_logs_sampling        = optional(number)
        subnet_flow_logs_metadata        = optional(string)
        subnet_flow_logs_filter          = optional(string)
        subnet_flow_logs_metadata_fields = optional(list(string))
        description                      = optional(string)
        purpose                          = optional(string)
        role                             = optional(string)
        stack_type                       = optional(string)
        ipv6_access_type                 = optional(string)
      })
    )
    secondary_ranges = optional(map(list(object({
      range_name    = string
      ip_cidr_range = string
    }))), {})
    firewall_rules = optional(object({
      egress = optional(list(object({
        name                    = string
        description             = optional(string, null)
        disabled                = optional(bool, null)
        priority                = optional(number, null)
        destination_ranges      = optional(list(string), [])
        source_ranges           = optional(list(string), [])
        source_tags             = optional(list(string))
        source_service_accounts = optional(list(string))
        target_tags             = optional(list(string))
        target_service_accounts = optional(list(string))

        allow = optional(list(object({
          protocol = string
          ports    = optional(list(string))
        })), [])
        deny = optional(list(object({
          protocol = string
          ports    = optional(list(string))
        })), [])
        log_config = optional(object({
          metadata = string
        }))
      })), []),
      ingress = optional(list(object({
        name                    = string
        description             = optional(string, null)
        disabled                = optional(bool, null)
        priority                = optional(number, null)
        destination_ranges      = optional(list(string), [])
        source_ranges           = optional(list(string), [])
        source_tags             = optional(list(string))
        source_service_accounts = optional(list(string))
        target_tags             = optional(list(string))
        target_service_accounts = optional(list(string))
        allow = optional(list(object({
          protocol = string
          ports    = optional(list(string))
        })), [])
        deny = optional(list(object({
          protocol = string
          ports    = optional(list(string))
        })), [])
        log_config = optional(object({
          metadata = string
        }))
      })), []),
    }), {})
  })
}


# Google Artifact Registry variables
variable "repository_name" {
  type        = string
  description = "Google Artifact Registry repository name for GKE"
}

variable "gcs_config" {
  type = object({
    bucket_name = string
  })
}

## GKE variables
variable "create_cluster" {
  type = bool
}

variable "private_cluster" {
  type    = bool
  default = true
}

variable "autopilot_cluster" {
  type = bool
}

variable "gke_config" {
  type = object({
    cluster_regional = bool
    cluster_name     = string
    cluster_labels = optional(map(string), {
      "gke_profile" = "ai-on-gke"
    })
    cluster_region                       = string
    cluster_zones                        = list(string)
    kubernetes_version                   = optional(string, "1.29.13-gke.1038000")
    release_channel                      = optional(string, "REGULAR")
    ip_range_pods                        = string
    ip_range_services                    = string
    monitoring_enable_managed_prometheus = bool
    master_ipv4_cidr_block               = optional(string)
    master_authorized_networks = optional(list(object({
      cidr_block   = string
      display_name = optional(string)
    })), [])
    cpu_pools                   = list(map(any))
    enable_gpu                  = optional(bool, true)
    gpu_pools                   = list(map(any))
    enable_tpu                  = optional(bool, false)
    tpu_pools                   = list(map(any))
    all_node_pools_oauth_scopes = list(string)
    all_node_pools_labels       = map(string)
    all_node_pools_metadata     = map(string)
    all_node_pools_tags         = list(string)
  })
}