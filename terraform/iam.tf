# Lambda Upload Role
resource "aws_iam_role" "lambda_upload" {
  name = "${var.project_name}-lambda-upload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_upload_basic" {
  role       = aws_iam_role.lambda_upload.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_upload_s3" {
  name = "S3UploadPolicy"
  role = aws_iam_role.lambda_upload.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:PutObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.uploads.arn}/*"
    }]
  })
}

# Lambda Process Role
resource "aws_iam_role" "lambda_process" {
  name = "${var.project_name}-lambda-process-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_process_basic" {
  role       = aws_iam_role.lambda_process.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_process_s3" {
  name = "S3ProcessPolicy"
  role = aws_iam_role.lambda_process.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.uploads.arn}/*"
    }]
  })
}

# App Runner Role
resource "aws_iam_role" "app_runner" {
  name = "${var.project_name}-app-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "app_runner_secrets" {
  name = "SecretManagerAccess"
  role = aws_iam_role.app_runner.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["secretsmanager:GetSecretValue"]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.db_password.arn
    }]
  })
}
