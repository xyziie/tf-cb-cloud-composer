variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "routing_mode" {
  description = "Routing mode: REGIONAL or GLOBAL"
  type        = string
  default     = "REGIONAL"
}

variable "delete_default_internet_gateway_routes" {
  description = "If true, deletes the default route to the internet gateway on creation"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name                  = string
    region                = string
    cidr                  = string
    private_google_access = optional(bool, true)
    description           = optional(string)
    secondary_ranges = optional(list(object({
      range_name = string
      cidr       = string
    })), [])
  }))
  default = []
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs on all subnets"
  type        = bool
  default     = true
}

variable "enable_cloud_nat" {
  description = "Enable Cloud NAT for outbound internet access from private instances"
  type        = bool
  default     = true
}

variable "nat_region" {
  description = "Region to deploy Cloud Router and NAT"
  type        = string
  default     = "us-central1"
}

variable "router_asn" {
  description = "ASN for the Cloud Router (used in BGP)"
  type        = number
  default     = 64514
}
