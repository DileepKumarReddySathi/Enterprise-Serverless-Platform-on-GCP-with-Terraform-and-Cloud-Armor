# Deployment Guide: Enterprise Serverless Platform on AWS

This document provides step-by-step instructions to deploy the platform on your AWS account.

## 📋 Prerequisites
- AWS CLI configured with Administrator access.
- Terraform installed.
- Docker installed (for App Runner build).

## 🚀 Deployment Steps

### Step 1: Initialize Infrastructure
```bash
cd terraform
terraform init
terraform plan -var="db_password=YOUR_SECURE_PASSWORD"
terraform apply -auto-approve -var="db_password=YOUR_SECURE_PASSWORD"
```

### Step 2: Push Web API to ECR
1. Authenticate Docker to ECR:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
   ```
2. Build and tag:
   ```bash
   cd services/web-api
   docker build -t web-api .
   docker tag web-api:latest YOUR_ECR_REPO_URL:latest
   ```
3. Push:
   ```bash
   docker push YOUR_ECR_REPO_URL:latest
   ```

### Step 3: Verify Deployment
- Retrieve the **API Gateway URL** from Terraform outputs.
- Test the health check: `curl <URL>/health`
- Test file upload: `curl -X POST -F "file=@test.txt" <URL>/upload`
