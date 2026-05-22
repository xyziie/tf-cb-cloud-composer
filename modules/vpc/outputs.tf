output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "Self-link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_ids" {
  description = "Map of subnet name → subnet ID"
  value = {
    for k, s in google_compute_subnetwork.subnets : k => s.id
  }
}

output "subnet_self_links" {
  description = "Map of subnet name → self_link"
  value = {
    for k, s in google_compute_subnetwork.subnets : k => s.self_link
  }
}

output "subnet_cidrs" {
  description = "Map of subnet name → CIDR"
  value = {
    for k, s in google_compute_subnetwork.subnets : k => s.ip_cidr_range
  }
}
