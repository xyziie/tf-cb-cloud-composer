variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "env" {
  description = "Environment name prefix for rule names"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network to attach rules to"
  type        = string
}

variable "enable_firewall_logging" {
  description = "Enable firewall rule logging (Firewall Insights)"
  type        = bool
  default     = true
}

variable "enable_default_deny_egress" {
  description = "Add a catch-all deny-all egress rule at priority 65534"
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "List of ingress firewall rules"
  type = list(object({
    name          = string
    description   = optional(string)
    priority      = optional(number, 1000)
    source_ranges = optional(list(string), [])
    source_tags   = optional(list(string), [])
    target_tags   = optional(list(string), [])   # <-- tagging approach
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress firewall rules"
  type = list(object({
    name               = string
    description        = optional(string)
    priority           = optional(number, 1000)
    destination_ranges = optional(list(string), ["0.0.0.0/0"])
    target_tags        = optional(list(string), [])   # <-- tagging approach
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = []
}
