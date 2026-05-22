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
    # bucket and prefix injected at `terraform init` time via -backend-config
    # bucket = "tf-state-<PROJECT_ID>-dev"
    # prefix = "terraform/state"
  }
}
