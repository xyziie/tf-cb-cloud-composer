output "composer_name" {
  description = "Name of the Cloud Composer environment"
  value       = google_composer_environment.this.name
}

output "airflow_uri" {
  description = "Airflow web UI URI"
  value       = google_composer_environment.this.config[0].airflow_uri
}

output "gcs_bucket" {
  description = "GCS bucket associated with the Composer environment"
  value       = google_composer_environment.this.config[0].dag_gcs_prefix
}

output "gke_cluster" {
  description = "GKE cluster used by Composer"
  value       = google_composer_environment.this.config[0].gke_cluster
}
