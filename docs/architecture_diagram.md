# Architecture Diagram

The diagram below illustrates the flow of requests and data within the Enterprise Serverless Platform on AWS.

```mermaid
graph TD
    User((User/Client)) --> WAF[AWS WAF]
    WAF --> AGW[API Gateway V2]
    
    AGW -- "POST /upload" --> LU[Lambda: function-upload]
    LU --> S3[(S3 Bucket: uploads)]
    
    S3 -- "ObjectCreated Event" --> LP[Lambda: function-process]
    LP --> CW[CloudWatch Logs]
    
    AGW -- "GET /api/items" --> AR[App Runner: web-api]
    AR --> SM[Secrets Manager]
    AR --> RDS[(RDS: PostgreSQL)]
    
    AR -- "Telemetry" --> XRay[AWS X-Ray]
    AR -- "Logs" --> CW
```

## Component Overview

- **AWS WAF**: Provides security against web attacks (SQLi, XSS) and DDoS.
- **API Gateway**: A serverless entry point that routes traffic to Lambda and App Runner.
- **AWS Lambda**: Handles event-driven tasks efficiently and scales to zero.
- **Amazon App Runner**: Simplifies container deployment, managing infrastructure and scaling automatically.
- **Amazon RDS**: Managed relational database for persistent state.
- **AWS Secrets Manager**: Protects sensitive credentials like DB passwords.
- **AWS X-Ray**: Enables distributed tracing to debug performance across services.
