output "folder_id" {
  description = "The folder ID (fully qualified: folders/<id>)"
  value       = google_folder.this.name
}

output "folder_display_name" {
  description = "Display name of the folder"
  value       = google_folder.this.display_name
}
