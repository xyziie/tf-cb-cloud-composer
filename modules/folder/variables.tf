variable "display_name" {
  description = "Display name for the GCP folder"
  type        = string
}

variable "parent" {
  description = "Parent resource. Format: 'organizations/<ORG_ID>' or 'folders/<FOLDER_ID>'"
  type        = string
}
