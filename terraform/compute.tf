# Lambda Upload
data "archive_file" "lambda_upload_zip" {
  type        = "zip"
  source_dir  = "../services/function-upload"
  output_path = "lambda_upload.zip"
}

resource "aws_lambda_function" "upload" {
  filename         = data.archive_file.lambda_upload_zip.output_path
  function_name    = "${var.project_name}-upload"
  role             = aws_iam_role.lambda_upload.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_upload_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.uploads.id
    }
  }
}

# Lambda Process
data "archive_file" "lambda_process_zip" {
  type        = "zip"
  source_dir  = "../services/function-process"
  output_path = "lambda_process.zip"
}

resource "aws_lambda_function" "process" {
  filename         = data.archive_file.lambda_process_zip.output_path
  function_name    = "${var.project_name}-process"
  role             = aws_iam_role.lambda_process.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_process_zip.output_base64sha256
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# App Runner (Web API)
resource "aws_ecr_repository" "web_api" {
  name = "${var.project_name}-web-api"
}

resource "aws_apprunner_service" "web_api" {
  service_name = "${var.project_name}-web-api"

  source_configuration {
    image_repository {
      image_identifier      = "${aws_ecr_repository.web_api.repository_url}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.main.arn
    }
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
    instance_role_arn = aws_iam_role.app_runner.arn
  }
}

resource "aws_apprunner_vpc_connector" "main" {
  vpc_connector_name = "${var.project_name}-vpc-connector"
  subnets            = aws_subnet.private[*].id
  security_groups    = [aws_security_group.rds.id]
}
