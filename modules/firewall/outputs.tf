output "ingress_rule_names" {
  description = "Names of created ingress firewall rules"
  value       = [for r in google_compute_firewall.ingress : r.name]
}

output "egress_rule_names" {
  description = "Names of created egress firewall rules"
  value       = [for r in google_compute_firewall.egress : r.name]
}
