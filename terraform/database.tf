resource "google_sql_database_instance" "postgres" {
  name             = "${var.project_name}-db"
  database_version = "POSTGRES_13"
  region           = var.gcp_region
  
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}

resource "google_sql_database" "database" {
  name     = "serverlessdb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "users" {
  name     = "user"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
