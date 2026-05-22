#!/usr/bin/env bash
################################################################################
# bootstrap/create_state_buckets.sh
#
# Run ONCE manually before any Terraform execution.
# Creates the GCS buckets used for remote Terraform state with versioning on.
#
# Usage:
#   chmod +x bootstrap/create_state_buckets.sh
#   ./bootstrap/create_state_buckets.sh <PROJECT_ID_DEV> <PROJECT_ID_PROD> <REGION>
#
# Example:
#   ./bootstrap/create_state_buckets.sh my-project-dev my-project-prod us-central1
################################################################################

set -euo pipefail

DEV_PROJECT="${1:?Usage: $0 <DEV_PROJECT_ID> <PROD_PROJECT_ID> <REGION>}"
PROD_PROJECT="${2:?Usage: $0 <DEV_PROJECT_ID> <PROD_PROJECT_ID> <REGION>}"
REGION="${3:-us-central1}"

ENVS=("dev" "prod")
PROJECTS=("$DEV_PROJECT" "$PROD_PROJECT")

for i in "${!ENVS[@]}"; do
  ENV="${ENVS[$i]}"
  PROJECT="${PROJECTS[$i]}"
  BUCKET="tf-state-${PROJECT}-${ENV}"

  echo "──────────────────────────────────────────"
  echo "Creating state bucket for: ${ENV} → gs://${BUCKET}"

  # Create bucket if not exists
  if gsutil ls -b "gs://${BUCKET}" &>/dev/null; then
    echo "  ✓ Bucket already exists, skipping creation."
  else
    gsutil mb \
      -p "${PROJECT}" \
      -l "${REGION}" \
      -b on \
      "gs://${BUCKET}"
    echo "  ✓ Bucket created."
  fi

  # Enable versioning
  gsutil versioning set on "gs://${BUCKET}"
  echo "  ✓ Versioning enabled."

  # Uniform bucket-level access
  gsutil uniformbucketlevelaccess set on "gs://${BUCKET}"
  echo "  ✓ Uniform bucket-level access enabled."

  # Prevent public access
  gsutil pap set enforced "gs://${BUCKET}"
  echo "  ✓ Public access prevention enforced."

done

echo ""
echo "✅  State buckets ready. You can now run Terraform."
