variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_iam_bindings" {
  description = "List of IAM bindings at project level"
  type = list(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}

variable "folder_iam_bindings" {
  description = "List of IAM bindings at folder level"
  type = list(object({
    folder  = string   # "folders/<FOLDER_ID>"
    role    = string
    members = list(string)
  }))
  default = []
}

variable "service_accounts" {
  description = "Service accounts to create and their project-level roles"
  type = list(object({
    account_id   = string
    display_name = string
    description  = optional(string)
    roles        = list(string)
  }))
  default = []
}
