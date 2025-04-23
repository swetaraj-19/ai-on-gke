module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  version    = "~> 10.0"
  project_id = var.project_id
  names      = [var.gcs_config.bucket_name]
  prefix     = var.project_id
  location   = var.region
  versioning = {
    enabled = true
  }
}