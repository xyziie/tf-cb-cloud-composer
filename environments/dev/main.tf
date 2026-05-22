################################################################################
# environments/dev/main.tf
# Wires together all modules for the DEV environment.
################################################################################

# ── Folder ────────────────────────────────────────────────────────────────────
# module "folder" {
#   source = "../../modules/folder"

#   display_name = "${var.env}-folder"
#   parent       = var.org_id   # "organizations/<ORG_ID>"
# }

# ── IAM ───────────────────────────────────────────────────────────────────────
module "iam" {
  source = "../../modules/iam"

  project_id = var.project_id

  service_accounts = [
    {
      account_id   = "composer-sa-${var.env}"
      display_name = "Cloud Composer SA (${var.env})"
      description  = "Service account for Cloud Composer workers"
      roles = [
        "roles/composer.worker",
        "roles/bigquery.dataEditor",
        "roles/storage.objectAdmin",
        "roles/logging.logWriter",
      ]
    },
    {
      account_id   = "terraform-sa-${var.env}"
      display_name = "Terraform Deployment SA (${var.env})"
      description  = "Service account used by Cloud Build / Terraform"
      roles = [
        "roles/editor",
        "roles/iam.securityAdmin",
      ]
    },
  ]

  project_iam_bindings = [
    {
      role    = "roles/viewer"
      members = var.viewer_members
    },
    {
      role    = "roles/editor"
      members = var.editor_members
    },
  ]
}

# ── VPC ───────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  project_id   = var.project_id
  env          = var.env
  network_name = "${var.env}-vpc"
  routing_mode = "REGIONAL"

  enable_flow_logs = true
  enable_cloud_nat = true
  nat_region       = var.region

  subnets = [
    {
      name   = "${var.env}-subnet-main"
      region = var.region
      cidr   = "10.10.0.0/20"
      secondary_ranges = [
        { range_name = "pods",     cidr = "10.20.0.0/16" },
        { range_name = "services", cidr = "10.30.0.0/20" },
      ]
    },
  ]
}

# ── Firewall ──────────────────────────────────────────────────────────────────
module "firewall" {
  source = "../../modules/firewall"

  project_id              = var.project_id
  env                     = var.env
  network_name            = module.vpc.network_name
  enable_firewall_logging = true

  ingress_rules = [
    # Allow IAP SSH/RDP to tagged VMs
    {
      name          = "allow-iap-ssh"
      description   = "Allow SSH from Identity-Aware Proxy"
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["allow-iap"]
      allow         = [{ protocol = "tcp", ports = ["22"] }]
    },
    # Allow internal traffic between all VMs on this network
    {
      name          = "allow-internal"
      description   = "Allow all internal traffic"
      source_ranges = ["10.10.0.0/20"]
      target_tags   = ["internal"]
      allow         = [{ protocol = "all" }]
    },
    # Allow health checks from GCP load balancers
    {
      name          = "allow-lb-health-checks"
      description   = "Allow GCP load balancer health checks"
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
      target_tags   = ["allow-health-check"]
      allow         = [{ protocol = "tcp" }]
    },
  ]

  egress_rules = [
    # Allow HTTPS egress for tagged VMs (e.g. Composer workers pulling images)
    {
      name               = "allow-https-egress"
      description        = "Allow HTTPS egress"
      target_tags        = ["allow-egress-https"]
      destination_ranges = ["0.0.0.0/0"]
      allow              = [{ protocol = "tcp", ports = ["443"] }]
    },
  ]
}

# ── Cloud Composer ────────────────────────────────────────────────────────────
module "composer" {
  source = "../../modules/composer"

  project_id    = var.project_id
  env           = var.env
  composer_name = "${var.env}-composer"
  region        = var.region
  image_version = var.composer_image_version

  environment_size = "ENVIRONMENT_SIZE_SMALL"

  # Scheduler resources (small for dev)
  scheduler_cpu        = 0.5
  scheduler_memory_gb  = 1.875
  scheduler_storage_gb = 1
  scheduler_count      = 1

  # Worker resources (small for dev)
  worker_cpu        = 0.5
  worker_memory_gb  = 1.875
  worker_storage_gb = 1
  worker_min_count  = 1
  worker_max_count  = 3

  network_id    = module.vpc.network_id
  subnetwork_id = module.vpc.subnet_ids["${var.env}-subnet-main"]

  composer_service_account_email = module.iam.service_account_emails["composer-sa-${var.env}"]

  pods_range_name     = "pods"
  services_range_name = "services"

  enable_private_endpoint = false   # dev: Airflow UI is accessible

  labels = {
    team = var.team_label
  }

  airflow_config_overrides = {
    "core-dags_are_paused_at_creation" = "True"
    "webserver-dag_orientation"        = "TB"
  }

  env_variables = var.composer_env_vars
  pypi_packages = var.composer_pypi_packages

  maintenance_window = {
    start_time = "2024-01-01T02:00:00Z"
    end_time   = "2024-01-01T06:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SU"
  }

  depends_on = [module.iam, module.vpc, module.firewall]
}
