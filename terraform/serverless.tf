resource "google_cloud_run_v2_service" "web_api" {
  name     = "${var.project_name}-web-api"
  location = var.gcp_region

  template {
    service_account = google_service_account.web_api_sa.email
    containers {
      image = "gcr.io/${var.gcp_project_id}/web-api:latest"
      env {
        name  = "DB_USER"
        value = "user"
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.database.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${google_sql_database_instance.postgres.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

resource "google_vpc_access_connector" "connector" {
  name          = "vpc-con"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.id
  region        = var.gcp_region
}

# Cloud Function: Upload
resource "google_cloudfunctions2_function" "function_upload" {
  name        = "function-upload"
  location    = var.gcp_region
  description = "Handles file uploads to GCS"

  build_config {
    runtime     = "nodejs18"
    entry_point = "handler"
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.upload_source.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.function_sa.email
    environment_variables = {
      BUCKET_NAME = google_storage_bucket.upload_bucket.name
    }
  }
}

# Cloud Function: Process
resource "google_cloudfunctions2_function" "function_process" {
  name        = "function-process"
  location    = var.gcp_region
  description = "Processes files uploaded to GCS"

  build_config {
    runtime     = "nodejs18"
    entry_point = "handler"
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.process_source.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.function_sa.email
  }

  event_trigger {
    trigger_region = var.gcp_region
    event_type     = "google.cloud.storage.object.v1.finalized"
    retry_policy   = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.function_sa.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.upload_bucket.name
    }
  }
}

resource "google_storage_bucket" "source_bucket" {
  name     = "${var.gcp_project_id}-gcf-source"
  location = var.gcp_region
}

resource "google_storage_bucket_object" "upload_source" {
  name   = "function-upload.zip"
  bucket = google_storage_bucket.source_bucket.name
  source = "services/function-upload/function-upload.zip" # Placeholder path
}

resource "google_storage_bucket_object" "process_source" {
  name   = "function-process.zip"
  bucket = google_storage_bucket.source_bucket.name
  source = "services/function-process/function-process.zip" # Placeholder path
}
