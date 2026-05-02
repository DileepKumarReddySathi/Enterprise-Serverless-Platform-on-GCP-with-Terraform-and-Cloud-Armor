resource "google_storage_bucket" "upload_bucket" {
  name          = "${var.gcp_project_id}-uploads"
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true
}
