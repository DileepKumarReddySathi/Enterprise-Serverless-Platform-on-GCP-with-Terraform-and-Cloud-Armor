# Deployment Guide: Enterprise Serverless Platform on GCP

This document provides step-by-step instructions to deploy the platform on your Google Cloud Project.

## 📋 Prerequisites
- **gcloud CLI** installed and authenticated.
- **Terraform** installed.
- **GCP Project** with billing enabled.

## 🚀 Deployment Steps

### Step 1: Enable Required APIs
```bash
gcloud services enable compute.googleapis.com \
                       sqladmin.googleapis.com \
                       run.googleapis.com \
                       cloudfunctions.googleapis.com \
                       secretmanager.googleapis.com \
                       cloudbuild.googleapis.com \
                       eventarc.googleapis.com \
                       vpcaccess.googleapis.com
```

### Step 2: Provision Infrastructure
```bash
cd terraform
terraform init
terraform apply -var="gcp_project_id=YOUR_PROJECT_ID" -var="db_password=YOUR_PASSWORD"
```

### Step 3: Deploy Services via Cloud Build
```bash
gcloud builds submit --config cloudbuild.yaml .
```

### Step 4: Verify Deployment
- Retrieve the **Cloud Run URL** and **Cloud Function URL**.
- Test the health check: `curl <CLOUD_RUN_URL>/health`
- Test file upload: `curl -X POST -F "file=@test.txt" <FUNCTION_UPLOAD_URL>`
