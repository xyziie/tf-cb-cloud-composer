################################################################################
# modules/iam/main.tf
################################################################################

# ── Project-level IAM bindings ────────────────────────────────────────────────
# Disabled for Qwiklabs — IAM policy updates blocked
# resource "google_project_iam_member" "project_bindings" {
#   for_each = {
#     for binding in local.flattened_project_bindings :
#     "${binding.role}__${binding.member}" => binding
#   }
#   project = var.project_id
#   role    = each.value.role
#   member  = each.value.member
#   dynamic "condition" {
#     for_each = each.value.condition != null ? [each.value.condition] : []
#     content {
#       title       = condition.value.title
#       description = lookup(condition.value, "description", null)
#       expression  = condition.value.expression
#     }
#   }
# }

# ── Folder-level IAM bindings (optional) ─────────────────────────────────────
# Disabled for Qwiklabs — no org/folder access
# resource "google_folder_iam_member" "folder_bindings" {
#   for_each = {
#     for binding in local.flattened_folder_bindings :
#     "${binding.folder}__${binding.role}__${binding.member}" => binding
#   }
#   folder = each.value.folder
#   role   = each.value.role
#   member = each.value.member
# }

# ── Service Account creation ──────────────────────────────────────────────────
resource "google_service_account" "accounts" {
  for_each = { for sa in var.service_accounts : sa.account_id => sa }

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = lookup(each.value, "description", null)
}

# ── SA role bindings ──────────────────────────────────────────────────────────
# Disabled for Qwiklabs — IAM policy updates blocked
# resource "google_project_iam_member" "sa_bindings" {
#   for_each = {
#     for pair in local.sa_role_pairs :
#     "${pair.account_id}__${pair.role}" => pair
#   }
#   project = var.project_id
#   role    = each.value.role
#   member  = "serviceAccount:${google_service_account.accounts[each.value.account_id].email}"
# }

################################################################################
# Locals
################################################################################
locals {
  flattened_project_bindings = flatten([
    for binding in var.project_iam_bindings : [
      for member in binding.members : {
        role      = binding.role
        member    = member
        condition = lookup(binding, "condition", null)
      }
    ]
  ])

  flattened_folder_bindings = flatten([
    for binding in var.folder_iam_bindings : [
      for member in binding.members : {
        folder = binding.folder
        role   = binding.role
        member = member
      }
    ]
  ])

  sa_role_pairs = flatten([
    for sa in var.service_accounts : [
      for role in sa.roles : {
        account_id = sa.account_id
        role       = role
      }
    ]
  ])
}