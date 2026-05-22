terraform {
  backend "gcs" {
    bucket = "tf-state-qwiklabs-gcp-01-3ba4b097d6eb-prod"
    prefix = "terraform/state"
  }
}
