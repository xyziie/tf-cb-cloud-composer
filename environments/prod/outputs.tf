# output "folder_id" {
#   description = "GCP Folder ID"
#   value       = module.folder.folder_id
# }

output "vpc_network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "subnet_cidrs" {
  description = "Subnet CIDRs"
  value       = module.vpc.subnet_cidrs
}

# output "composer_airflow_uri" {
#   description = "Airflow web UI URI"
#   value       = module.composer.airflow_uri
# }

# output "composer_gcs_bucket" {
#   description = "Composer DAG bucket"
#   value       = module.composer.gcs_bucket
# }

# output "service_account_emails" {
#   description = "Created service account emails"
#   value       = module.iam.service_account_emails
# }
