################################################################################
# environments/dev/terraform.tfvars
# ⚠️  Do NOT commit secrets here. Use Secret Manager or GitHub Secrets for
#     sensitive values and inject them as env vars at apply time.
################################################################################

project_id = "qwiklabs-gcp-01-3ba4b097d6eb"
region     = "us-central1"
env        = "dev"
org_id     = ""  # Not available in Qwiklabs

team_label = "platform"

viewer_members = []  # No groups in Qwiklabs

editor_members = []  # No groups in Qwiklabs

composer_image_version = "composer-2.6.6-airflow-2.7.3"

composer_pypi_packages = {
  "apache-airflow-providers-google" = ">=10.0.0"
  "pandas"                          = ">=2.0.0"
}