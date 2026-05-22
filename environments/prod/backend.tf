terraform {
  backend "gcs" {
    # bucket and prefix injected at `terraform init` time via -backend-config
    # bucket = "tf-state-<PROJECT_ID>-prod"
    # prefix = "terraform/state"
  }
}
