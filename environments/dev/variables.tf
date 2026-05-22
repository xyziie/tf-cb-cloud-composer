variable "project_id" {
  description = "GCP Project ID for the dev environment"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "org_id" {
  description = "GCP Organization ID (format: organizations/<id>)"
  type        = string
}

variable "team_label" {
  description = "Team label applied to resources"
  type        = string
  default     = "platform"
}

variable "viewer_members" {
  description = "List of IAM members granted roles/viewer"
  type        = list(string)
  default     = []
}

variable "editor_members" {
  description = "List of IAM members granted roles/editor"
  type        = list(string)
  default     = []
}

variable "composer_image_version" {
  description = "Cloud Composer image version"
  type        = string
  default     = "composer-2.6.6-airflow-2.7.3"
}

variable "composer_env_vars" {
  description = "Environment variables for Composer workers"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "composer_pypi_packages" {
  description = "Extra PyPI packages for Composer"
  type        = map(string)
  default     = {}
}
