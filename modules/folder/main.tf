################################################################################
# modules/folder/main.tf
# Creates a GCP Folder under an Organization or parent folder.
################################################################################

resource "google_folder" "this" {
  display_name = var.display_name
  parent       = var.parent  # "organizations/<ORG_ID>" or "folders/<FOLDER_ID>"
}
