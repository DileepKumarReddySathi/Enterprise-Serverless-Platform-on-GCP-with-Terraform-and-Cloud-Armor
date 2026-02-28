# Enterprise Serverless Platform on AWS

This repository contains a production-grade, multi-service serverless application built on **Amazon Web Services (AWS)** using **Terraform**.

> [!NOTE]
> **Platform Choice Notice**: This project was originally designed for Google Cloud Platform (GCP). However, due to persistent technical errors encountered during the GCP account creation and activation process, the implementation has been migrated to **AWS**. All requirements (Serverless compute, SQL database, WAF, Secrets Management, etc.) have been fully mapped and implemented using equivalent AWS services.

## 🏗️ Architecture

The platform consists of:
- **Networking**: Custom VPC with public/private subnets across multiple AZs.
- **Compute**:
  - **AWS Lambda**: Event-driven file processing and authenticated uploads.
  - **AWS App Runner**: Containerized Go/Gin Web API.
- **Database**: Amazon RDS for PostgreSQL (private).
- **Security**:
  - **AWS WAF**: Web Application Firewall protecting the API.
  - **AWS Secrets Manager**: Secure management of database credentials.
  - **IAM**: Least-privilege roles for all services.
- **Observability**: Structured logging with **CloudWatch** and distributed tracing with **AWS X-Ray**.

## 🚀 Getting Started

### Local Development
1. Clone the repository.
2. Copy `.env.example` to `.env`.
3. Launch the environment:
   ```powershell
   .\launch.ps1
   ```
   *Alternatively, run `docker-compose up -d --build`.*

### Deployment
Refer to the [Deployment Guide](docs/deployment_guide.md) for full instructions on provisioning the AWS infrastructure.

---

## 🛠️ Built With
- **Terraform**: Infrastructure as Code.
- **Go / Gin**: High-performance Web API.
- **Node.js**: Serverless Lambda functions.
- **Docker**: Containerization.
- **AWS**: Core cloud platform.
# Enterprise-Serverless-Platform-on-GCP-with-Terraform-and-Cloud-Armor
