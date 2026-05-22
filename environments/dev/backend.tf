################################################################################
# environments/dev/backend.tf
# Remote state stored in GCS with versioning (versioning enabled on bucket
# via bootstrap/create_state_buckets.sh).
#
# bucket and prefix are passed dynamically via -backend-config in cloudbuild.yaml
# so this file only declares the backend TYPE.
################################################################################

terraform {
  backend "gcs" {
    bucket = "tf-state-qwiklabs-gcp-01-3ba4b097d6eb-dev"
    prefix = "terraform/state"
  }
}
