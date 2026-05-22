################################################################################
# environments/prod/main.tf
# Wires together all modules for the PROD environment.
# Prod uses larger Composer resources, private endpoints, and deny-all egress.
################################################################################

# module "folder" {
#   source = "../../modules/folder"

#   display_name = "${var.env}-folder"
#   parent       = var.org_id
# }

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

module "vpc" {
  source = "../../modules/vpc"

  project_id   = var.project_id
  env          = var.env
  network_name = "${var.env}-vpc"
  routing_mode = "GLOBAL"   # prod uses global routing

  enable_flow_logs = true
  enable_cloud_nat = true
  nat_region       = var.region

  # Prod has multiple subnets across regions
  subnets = [
    {
      name   = "${var.env}-subnet-main"
      region = var.region
      cidr   = "10.100.0.0/20"
      secondary_ranges = [
        { range_name = "pods",     cidr = "10.200.0.0/16" },
        { range_name = "services", cidr = "10.210.0.0/20" },
      ]
    },
    {
      name   = "${var.env}-subnet-secondary"
      region = var.secondary_region
      cidr   = "10.110.0.0/20"
    },
  ]
}

module "firewall" {
  source = "../../modules/firewall"

  project_id                 = var.project_id
  env                        = var.env
  network_name               = module.vpc.network_name
  enable_firewall_logging    = true
  enable_default_deny_egress = true   # stricter for prod

  ingress_rules = [
    {
      name          = "allow-iap-ssh"
      description   = "Allow SSH from Identity-Aware Proxy"
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["allow-iap"]
      allow         = [{ protocol = "tcp", ports = ["22"] }]
    },
    {
      name          = "allow-internal"
      description   = "Allow all internal traffic"
      source_ranges = ["10.100.0.0/20", "10.110.0.0/20"]
      target_tags   = ["internal"]
      allow         = [{ protocol = "all" }]
    },
    {
      name          = "allow-lb-health-checks"
      description   = "Allow GCP load balancer health checks"
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
      target_tags   = ["allow-health-check"]
      allow         = [{ protocol = "tcp" }]
    },
  ]

  egress_rules = [
    {
      name               = "allow-https-egress"
      description        = "Allow HTTPS egress for tagged VMs"
      target_tags        = ["allow-egress-https"]
      destination_ranges = ["0.0.0.0/0"]
      priority           = 900   # beats the deny-all at 65534
      allow              = [{ protocol = "tcp", ports = ["443"] }]
    },
    {
      name               = "allow-google-apis-egress"
      description        = "Allow egress to Google APIs via Private Google Access"
      target_tags        = ["allow-egress-google-apis"]
      destination_ranges = ["199.36.153.8/30"]
      priority           = 900
      allow              = [{ protocol = "tcp", ports = ["443"] }]
    },
  ]
}

module "composer" {
  source = "../../modules/composer"

  project_id    = var.project_id
  env           = var.env
  composer_name = "${var.env}-composer"
  region        = var.region
  image_version = var.composer_image_version

  environment_size = "ENVIRONMENT_SIZE_MEDIUM"   # larger for prod

  scheduler_cpu        = 2
  scheduler_memory_gb  = 7.5
  scheduler_storage_gb = 10
  scheduler_count      = 2   # HA schedulers

  worker_cpu        = 2
  worker_memory_gb  = 7.5
  worker_storage_gb = 10
  worker_min_count  = 3
  worker_max_count  = 10

  web_server_cpu       = 1
  web_server_memory_gb = 3.75

  network_id    = module.vpc.network_id
  subnetwork_id = module.vpc.subnet_ids["${var.env}-subnet-main"]

  composer_service_account_email = module.iam.service_account_emails["composer-sa-${var.env}"]

  pods_range_name     = "pods"
  services_range_name = "services"

  enable_private_endpoint = true   # Airflow UI is private in prod

  labels = {
    team = var.team_label
  }

  airflow_config_overrides = {
    "core-dags_are_paused_at_creation" = "True"
    "scheduler-catchup_by_default"     = "False"
  }

  env_variables = var.composer_env_vars
  pypi_packages = var.composer_pypi_packages

  maintenance_window = {
    start_time = "2024-01-01T03:00:00Z"
    end_time   = "2024-01-01T07:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SA"
  }

  depends_on = [module.iam, module.vpc, module.firewall]
}
