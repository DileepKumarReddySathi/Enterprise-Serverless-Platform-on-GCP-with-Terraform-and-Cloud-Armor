# Operational Runbook: Investigating High Error Rates (5xx)

This runbook describes the steps to investigate and remediate a spike in 5xx errors in the Enterprise Serverless Platform.

## 1. Initial Assessment
- **Check CloudWatch Metrics**: Look for spikes in `5XXError` metrics on the API Gateway and `HTTP5xx` on the App Runner service.
- **Trace the Request**: Use **AWS X-Ray** to find failing traces. Identify which component (App Runner, Lambda, or RDS) is the bottleneck or source of the error.

## 2. Component Troubleshooting

### App Runner (Web API)
- **Logs**: Check App Runner service logs in CloudWatch Logs for "panic", "timeout", or "DB connection failed".
- **Database Connectivity**: Verify the RDS status. Ensure the App Runner VPC connector is healthy and security groups allow traffic on port 5432.
- **Secrets**: Check if Secrets Manager is reachable and the secret exists.

### Lambda (Upload/Process)
- **Logs**: Search for "Runtime error" or "AccessDenied" in Lambda log groups.
- **Quotas**: Check if the function is being throttled (concurrency limits).

### RDS (Database)
- **Status**: Check the RDS instance status (e.g., `backing up`, `rebooting`, `inaccessible`).
- **Connections**: Ensure the maximum number of connections hasn't been reached.

## 3. Remediation Steps
- **Restart**: If App Runner is sticking, trigger a redeploy or manual deployment in the console.
- **Scale Up**: If RDS is at 100% CPU, consider upgrading the instance class via Terraform.
- **WAF**: If the errors are caused by a malicious traffic spike, add the offending IP to the WAF `BlockIP` rule in `api_gateway.tf`.
