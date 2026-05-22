################################################################################
# modules/firewall/main.tf
#
# Tag-based firewall approach:
#   - Rules use `target_tags` so they apply only to VMs with matching network tags.
#   - Ingress and egress rules are defined separately for clarity.
#   - A default "deny all egress" rule can be optionally enforced.
################################################################################

locals {
  # Merge custom rules list into a map keyed by rule name
  ingress_rules = {
    for rule in var.ingress_rules : rule.name => rule
  }
  egress_rules = {
    for rule in var.egress_rules : rule.name => rule
  }
}

# ── Ingress Rules ─────────────────────────────────────────────────────────────
resource "google_compute_firewall" "ingress" {
  for_each = local.ingress_rules

  project     = var.project_id
  name        = "${var.env}-${each.key}"
  network     = var.network_name
  description = lookup(each.value, "description", "Managed by Terraform")
  direction   = "INGRESS"
  priority    = lookup(each.value, "priority", 1000)

  # Tag-based targeting: rule applies only to VMs with these network tags
  target_tags = lookup(each.value, "target_tags", [])

  # Source filtering
  source_ranges = lookup(each.value, "source_ranges", [])
  source_tags   = lookup(each.value, "source_tags", [])

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", [])
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", [])
    }
  }

  log_config {
    metadata = var.enable_firewall_logging ? "INCLUDE_ALL_METADATA" : "EXCLUDE_ALL_METADATA"
  }
}

# ── Egress Rules ──────────────────────────────────────────────────────────────
resource "google_compute_firewall" "egress" {
  for_each = local.egress_rules

  project     = var.project_id
  name        = "${var.env}-${each.key}"
  network     = var.network_name
  description = lookup(each.value, "description", "Managed by Terraform")
  direction   = "EGRESS"
  priority    = lookup(each.value, "priority", 1000)

  target_tags        = lookup(each.value, "target_tags", [])
  destination_ranges = lookup(each.value, "destination_ranges", ["0.0.0.0/0"])

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", [])
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", [])
    }
  }

  log_config {
    metadata = var.enable_firewall_logging ? "INCLUDE_ALL_METADATA" : "EXCLUDE_ALL_METADATA"
  }
}

# ── Default deny-all egress (optional, high priority = lower number) ──────────
resource "google_compute_firewall" "deny_all_egress" {
  count = var.enable_default_deny_egress ? 1 : 0

  project     = var.project_id
  name        = "${var.env}-deny-all-egress"
  network     = var.network_name
  description = "Default deny all egress — override with lower-priority rules"
  direction   = "EGRESS"
  priority    = 65534

  destination_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
