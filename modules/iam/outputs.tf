output "service_account_emails" {
  description = "Map of account_id → email for created service accounts"
  value = {
    for k, sa in google_service_account.accounts : k => sa.email
  }
}

output "service_account_ids" {
  description = "Map of account_id → unique_id for created service accounts"
  value = {
    for k, sa in google_service_account.accounts : k => sa.unique_id
  }
}
