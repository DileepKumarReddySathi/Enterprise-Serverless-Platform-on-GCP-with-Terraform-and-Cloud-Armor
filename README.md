# Enterprise Serverless Platform on GCP

This repository contains a production-grade, multi-service serverless application built on **Google Cloud Platform (GCP)** using **Terraform**.

## 🏗️ Architecture

The platform consists of:
- **Networking**: Custom VPC with private subnets and VPC Access Connector for serverless-to-VPC communication.
- **Compute**:
  - **GCP Cloud Functions**: Event-driven file processing and authenticated uploads.
  - **GCP Cloud Run**: Containerized Go/Gin Web API.
- **Database**: **Cloud SQL** for PostgreSQL (private IP only).
- **Security**:
  - **Cloud Armor**: Web Application Firewall protecting the platform.
  - **Secret Manager**: Secure management of database credentials, injected into Cloud Run.
  - **IAM**: Least-privilege Service Accounts for all services.
- **Observability**: Structured logging with **Cloud Logging** and custom metrics with **Cloud Monitoring**.

## 🚀 Getting Started

### Local Development
1. Clone the repository.
2. Copy `.env.example` to `.env`.
3. Launch the environment:
   ```bash
   docker-compose up -d --build
   ```

### Deployment
Deployment is automated via **GCP Cloud Build**.
1. Ensure the Cloud Build API is enabled.
2. Run the build:
   ```bash
   gcloud builds submit --config cloudbuild.yaml .
   ```

---

## 🛠️ Built With
- **Terraform**: Infrastructure as Code.
- **Go / Gin**: High-performance Web API.
- **Node.js**: Cloud Functions.
- **Docker**: Containerization.
- **GCP**: Core cloud platform.
