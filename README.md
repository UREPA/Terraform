# Cheap WordPress on GCP with Terraform

This project provisions a minimal-cost WordPress deployment on Google Cloud Platform using Terraform. It is designed for personal or experimental use, not for production.

## Features
- Google Compute Engine (GCE) VM for WordPress
- Minimal resources for lowest cost
- Persistent disk for WordPress data
- Firewall rules for HTTP/HTTPS

## Prerequisites
- Terraform installed
- Google Cloud account and project
- Service account with necessary permissions
- Billing enabled on GCP

## Usage
1. Copy your GCP service account key to this directory as `account.json`.
2. Edit `main.tf` to set your project and region.
3. Run:
   ```pwsh
   terraform init
   terraform plan
   terraform apply
   ```

## Clean up
To avoid ongoing charges, run:
```pwsh
terraform destroy
```

---
This is a minimal, cost-focused setup. For production, consider managed WordPress or GKE.
