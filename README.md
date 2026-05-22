# GCP Terraform Modular Infrastructure

## Structure

```
gcp-terraform/
├── environments/
│   ├── dev/
│   └── prod/
├── modules/
│   ├── folder/
│   ├── iam/
│   ├── vpc/
│   ├── firewall/
│   └── composer/
├── .github/
│   └── workflows/
│       └── terraform.yml
└── cloudbuild.yaml
```

## Environments
- **dev** — Development environment
- **prod** — Production environment
- Additional environments can be added by copying an environment folder and updating `terraform.tfvars`.

## Remote State
Each environment stores its Terraform state in a dedicated GCS bucket with versioning enabled.

## CI/CD
GitHub Actions triggers Cloud Build on push to `main` (prod) or `develop` (dev).
Cloud Build runs `terraform init`, `plan`, and `apply`.
# tf-cb-cloud-composer
