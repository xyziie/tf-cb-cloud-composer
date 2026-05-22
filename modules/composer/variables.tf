variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "composer_name" {
  description = "Name for the Cloud Composer environment"
  type        = string
}

variable "region" {
  description = "GCP region for the Composer environment"
  type        = string
}

variable "image_version" {
  description = "Cloud Composer image version (e.g. composer-2.6.6-airflow-2.7.3)"
  type        = string
  default     = "composer-2.6.6-airflow-2.7.3"
}

variable "labels" {
  description = "Additional labels to apply"
  type        = map(string)
  default     = {}
}

variable "airflow_config_overrides" {
  description = "Airflow configuration overrides (section-key = value)"
  type        = map(string)
  default     = {}
}

variable "env_variables" {
  description = "Environment variables available to Airflow workers"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "pypi_packages" {
  description = "Additional PyPI packages to install"
  type        = map(string)
  default     = {}
}

variable "environment_size" {
  description = "Composer 2 environment size: ENVIRONMENT_SIZE_SMALL / MEDIUM / LARGE"
  type        = string
  default     = "ENVIRONMENT_SIZE_SMALL"
}

# ── Scheduler ─────────────────────────────────────────────────────────────────
variable "scheduler_cpu" {
  type    = number
  default = 0.5
}
variable "scheduler_memory_gb" {
  type    = number
  default = 1.875
}
variable "scheduler_storage_gb" {
  type    = number
  default = 1
}
variable "scheduler_count" {
  type    = number
  default = 1
}

# ── Web Server ────────────────────────────────────────────────────────────────
variable "web_server_cpu" {
  type    = number
  default = 0.5
}
variable "web_server_memory_gb" {
  type    = number
  default = 1.875
}

# ── Workers ───────────────────────────────────────────────────────────────────
variable "worker_cpu" {
  type    = number
  default = 0.5
}
variable "worker_memory_gb" {
  type    = number
  default = 1.875
}
variable "worker_storage_gb" {
  type    = number
  default = 1
}
variable "worker_min_count" {
  type    = number
  default = 1
}
variable "worker_max_count" {
  type    = number
  default = 3
}

# ── Networking ────────────────────────────────────────────────────────────────
variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnetwork_id" {
  description = "Subnetwork ID for Composer nodes"
  type        = string
}

variable "composer_service_account_email" {
  description = "Service account email used by Composer worker nodes"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary IP range name for GKE pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary IP range name for GKE services"
  type        = string
}

variable "enable_private_endpoint" {
  description = "If true, Composer web UI is not publicly accessible"
  type        = bool
  default     = false
}

variable "composer_network_cidr" {
  description = "CIDR for the Composer tenant project network"
  type        = string
  default     = "172.16.0.0/22"
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    start_time = string   # RFC3339 e.g. "2024-01-01T00:00:00Z"
    end_time   = string
    recurrence = string   # RRULE e.g. "FREQ=WEEKLY;BYDAY=SU"
  })
  default = null
}
