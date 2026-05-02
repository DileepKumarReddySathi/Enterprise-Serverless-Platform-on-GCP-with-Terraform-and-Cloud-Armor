resource "google_service_account" "web_api_sa" {
  account_id   = "web-api-sa"
  display_name = "Web API Service Account"
}

resource "google_service_account" "function_sa" {
  account_id   = "function-sa"
  display_name = "Cloud Functions Service Account"
}

# Grant Cloud SQL Client role
resource "google_project_iam_member" "web_api_sql_client" {
  project = var.gcp_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.web_api_sa.email}"
}

# Grant Secret Manager Secret Accessor role
resource "google_project_iam_member" "web_api_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.web_api_sa.email}"
}

# Grant Storage Object Admin to function SA
resource "google_project_iam_member" "function_storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant Pub/Sub Publisher to GCS for Eventarc
resource "google_project_iam_member" "gcs_pubsub_publisher" {
  project = var.gcp_project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

data "google_project" "project" {}
