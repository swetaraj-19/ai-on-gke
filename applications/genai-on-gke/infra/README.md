# GKE Infrastructure for Gen AI

## Description

This Terraform module provisions the foundational infrastructure on Google Cloud Platform (GCP) required to deploy and run Generative AI (GenAI) workloads, potentially including models like Llama, on Google Kubernetes Engine (GKE).

It automates the setup of networking resources (VPC, Subnets, Firewall Rules, Cloud NAT), a GKE cluster optimized for AI/ML tasks (including options for private clusters and GPU nodes), Google Cloud Storage (GCS) buckets for artifacts/data, and Google Artifact Registry for container images.

## Prerequisites

Before applying this Terraform configuration, ensure the following prerequisites are met for the target GCP project:

1.  **GCP Project:** A GCP project exists.
2.  **Billing:** Billing is enabled for the project.
3.  **Permissions:** The user or service account executing Terraform has sufficient IAM permissions. 
4.  **APIs Enabled:** Core APIs are enabled. This module will attempt to enable the APIs listed in the `api_services` input.
5.  **Quotas:** Sufficient quotas are available for the resources being created, especially:
    * Compute Engine resources (VMs, IPs, Disks)
    * GKE Clusters
    * GPU quotas (if deploying GPU node pools) in the specified region (`us-central1` by default).
6. **GCS Bucket for Terraform State:** Create a GCS bucket *manually* beforehand to store the Terraform state files remotely. This is crucial for collaboration and state locking. Configure this bucket in your `backend.tf` file.

## Usage:

This section details how to configure and deploy the module.

### Example `terraform.tfvars`

```hcl
project_id = "your-gcp-project-id" # Replace with your Project ID
region     = "us-central1"

create_network = true
network_config = {
  network_name = "gke-genai-network" # Renamed to avoid potential conflicts
  subnets = [{
    subnet_name           = "gke-genai-subnet"
    subnet_ip             = "10.100.0.0/16"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    description           = "Primary subnet for GKE GenAI workloads"
  }]
  secondary_ranges = {
    # The key here MUST match the subnet_name from the subnets list above
    "gke-genai-subnet" = [
      {
        range_name    = "pods"        # Simplified name, module might add prefixes
        ip_cidr_range = "192.168.0.0/20"
      },
      {
        range_name    = "services"    # Simplified name, module might add prefixes
        ip_cidr_range = "192.168.48.0/20"
      }
    ]
  }
  # Optional: Add firewall rules here if needed.
  # firewall_rules = { ... }
}
gcs_config = {
  bucket_name = "your-genai-artifacts-bucket" # Choose a globally unique name
  # location    = "US-CENTRAL1" # Optional: Specify location
}
repository_name = "gke-genai-repo" # No underscores allowed
private_cluster = true

# Optional: Override default API list if necessary
# api_services = [ ... ]

# Optional: Override default service config if necessary
# service_config = { ... }
```

## Initialization and Deployment:

Execute the following commands from the directory containing your Terraform files (main.tf, backend.tf, terraform.tfvars):

1. Navigate to the directory containing your main.tf and update `terraform.tfvars`.
2. Update `backend.tf` with the GCS Bucket name.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.

## APIs Enabled
This module enables the APIs listed in the [api_services](apis.tf) input variable.The default list includes common services for GKE, networking, storage, and registry.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_artifact_registry"></a> [artifact\_registry](#module\_artifact\_registry) | GoogleCloudPlatform/artifact-registry/google | ~> 0.3 |
| <a name="module_cloud-nat"></a> [cloud-nat](#module\_cloud-nat) | terraform-google-modules/cloud-nat/google | 5.0.0 |
| <a name="module_firewall_rules"></a> [firewall\_rules](#module\_firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | 9.1.0 |
| <a name="module_gcs_buckets"></a> [gcs\_buckets](#module\_gcs\_buckets) | terraform-google-modules/cloud-storage/google | ~> 10.0 |
| <a name="module_vpc_network"></a> [vpc\_network](#module\_vpc\_network) | terraform-google-modules/network/google | 8.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.project_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_services"></a> [api\_services](#input\_api\_services) | Service APIs to enable. | `list(string)` | `[]` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | n/a | `bool` | n/a | yes |
| <a name="input_gcs_config"></a> [gcs\_config](#input\_gcs\_config) | n/a | <pre>object({<br>    bucket_name   = string<br>  })</pre> | n/a | yes |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Network Configuration | <pre>object({<br>    network_name                           = string<br>    routing_mode                           = optional(string, "GLOBAL")<br>    delete_default_internet_gateway_routes = optional(bool, true)<br>    reserve_static_ip                      = optional(bool, false)<br>    subnets = list(object(<br>      {<br>        subnet_name                      = string,<br>        subnet_ip                        = string,<br>        subnet_region                    = string,<br>        subnet_private_access            = string,<br>        subnet_private_ipv6_access       = optional(string)<br>        subnet_flow_logs                 = optional(string)<br>        subnet_flow_logs_interval        = optional(string)<br>        subnet_flow_logs_sampling        = optional(number)<br>        subnet_flow_logs_metadata        = optional(string)<br>        subnet_flow_logs_filter          = optional(string)<br>        subnet_flow_logs_metadata_fields = optional(list(string))<br>        description                      = optional(string)<br>        purpose                          = optional(string)<br>        role                             = optional(string)<br>        stack_type                       = optional(string)<br>        ipv6_access_type                 = optional(string)<br>      })<br>    )<br>    secondary_ranges = optional(map(list(object({<br>      range_name    = string<br>      ip_cidr_range = string<br>    }))), {})<br>    firewall_rules = optional(object({<br>      egress = optional(list(object({<br>        name                    = string<br>        description             = optional(string, null)<br>        disabled                = optional(bool, null)<br>        priority                = optional(number, null)<br>        destination_ranges      = optional(list(string), [])<br>        source_ranges           = optional(list(string), [])<br>        source_tags             = optional(list(string))<br>        source_service_accounts = optional(list(string))<br>        target_tags             = optional(list(string))<br>        target_service_accounts = optional(list(string))<br><br>        allow = optional(list(object({<br>          protocol = string<br>          ports    = optional(list(string))<br>        })), [])<br>        deny = optional(list(object({<br>          protocol = string<br>          ports    = optional(list(string))<br>        })), [])<br>        log_config = optional(object({<br>          metadata = string<br>        }))<br>      })), []),<br>      ingress = optional(list(object({<br>        name                    = string<br>        description             = optional(string, null)<br>        disabled                = optional(bool, null)<br>        priority                = optional(number, null)<br>        destination_ranges      = optional(list(string), [])<br>        source_ranges           = optional(list(string), [])<br>        source_tags             = optional(list(string))<br>        source_service_accounts = optional(list(string))<br>        target_tags             = optional(list(string))<br>        target_service_accounts = optional(list(string))<br>        allow = optional(list(object({<br>          protocol = string<br>          ports    = optional(list(string))<br>        })), [])<br>        deny = optional(list(object({<br>          protocol = string<br>          ports    = optional(list(string))<br>        })), [])<br>        log_config = optional(object({<br>          metadata = string<br>        }))<br>      })), []),<br>    }), {})<br>  })</pre> | n/a | yes |
| <a name="input_private_cluster"></a> [private\_cluster](#input\_private\_cluster) | n/a | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project id | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP project region or zone | `string` | `"us-central1"` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Google Artifact Registry repository name for GKE | `string` | n/a | yes |
| <a name="input_service_config"></a> [service\_config](#input\_service\_config) | Configure service API activation. | <pre>object({<br>    disable_on_destroy         = bool<br>    disable_dependent_services = bool<br>  })</pre> | <pre>{<br>  "disable_dependent_services": false,<br>  "disable_on_destroy": false<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->