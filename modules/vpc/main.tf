################################################################################
# modules/vpc/main.tf
# Creates a VPC network with subnets, secondary ranges, and Cloud NAT.
################################################################################

# ── VPC Network ───────────────────────────────────────────────────────────────
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  description             = "VPC network for ${var.env} environment"

  delete_default_routes_on_create = var.delete_default_internet_gateway_routes
}

# ── Subnets ───────────────────────────────────────────────────────────────────
resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  project                  = var.project_id
  name                     = each.value.name
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = each.value.cidr
  private_ip_google_access = lookup(each.value, "private_google_access", true)
  description              = lookup(each.value, "description", null)

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.cidr
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# ── Cloud Router (for Cloud NAT) ──────────────────────────────────────────────
resource "google_compute_router" "router" {
  count   = var.enable_cloud_nat ? 1 : 0
  project = var.project_id
  name    = "${var.network_name}-router"
  region  = var.nat_region
  network = google_compute_network.vpc.id

  bgp {
    asn = var.router_asn
  }
}

# ── Cloud NAT ─────────────────────────────────────────────────────────────────
resource "google_compute_router_nat" "nat" {
  count   = var.enable_cloud_nat ? 1 : 0
  project = var.project_id
  name    = "${var.network_name}-nat"
  router  = google_compute_router.router[0].name
  region  = var.nat_region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
