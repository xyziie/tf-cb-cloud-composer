################################################################################
# modules/composer/main.tf
# Cloud Composer 2 (Airflow) environment — private, VPC-native.
################################################################################

# ── Cloud Composer 2 Environment ──────────────────────────────────────────────
resource "google_composer_environment" "this" {
  project = var.project_id
  name    = var.composer_name
  region  = var.region

  labels = merge(var.labels, {
    env       = var.env
    managed   = "terraform"
  })

  config {
    # ── Software configuration ──────────────────────────────────────────────
    software_config {
      image_version  = var.image_version   # e.g. "composer-2.6.6-airflow-2.7.3"
      python_version = "3"

      airflow_config_overrides = var.airflow_config_overrides
      env_variables            = var.env_variables
      pypi_packages            = var.pypi_packages
    }

    # ── Node configuration (Composer 2 workloads) ───────────────────────────
    workloads_config {
      scheduler {
        cpu        = var.scheduler_cpu
        memory_gb  = var.scheduler_memory_gb
        storage_gb = var.scheduler_storage_gb
        count      = var.scheduler_count
      }
      web_server {
        cpu       = var.web_server_cpu
        memory_gb = var.web_server_memory_gb
      }
      worker {
        cpu        = var.worker_cpu
        memory_gb  = var.worker_memory_gb
        storage_gb = var.worker_storage_gb
        min_count  = var.worker_min_count
        max_count  = var.worker_max_count
      }
    }

    environment_size = var.environment_size   # ENVIRONMENT_SIZE_SMALL / MEDIUM / LARGE

    # ── Network (private, VPC-native) ───────────────────────────────────────
    node_config {
      network         = var.network_id
      subnetwork      = var.subnetwork_id
      service_account = var.composer_service_account_email

      ip_allocation_policy {
        cluster_secondary_range_name  = var.pods_range_name
        services_secondary_range_name = var.services_range_name
      }
    }

    # ── Private environment ─────────────────────────────────────────────────
    private_environment_config {
      enable_private_endpoint                = var.enable_private_endpoint
      cloud_composer_network_ipv4_cidr_block = var.composer_network_cidr
    }

    # ── Maintenance window ──────────────────────────────────────────────────
    dynamic "maintenance_window" {
      for_each = var.maintenance_window != null ? [var.maintenance_window] : []
      content {
        start_time = maintenance_window.value.start_time
        end_time   = maintenance_window.value.end_time
        recurrence = maintenance_window.value.recurrence
      }
    }
  }

  timeouts {
    create = "90m"
    update = "60m"
    delete = "60m"
  }
}
