resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "default" {
  count      = var.attach_basic_execution_role ? 1 : 0
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = aws_iam_role.lambda_exec.arn

  # ZIP-based
  filename         = var.image_uri == null ? var.filename : null
  s3_bucket        = var.image_uri == null ? var.s3_bucket : null
  s3_key           = var.image_uri == null ? var.s3_key : null
  source_code_hash = var.image_uri == null ? var.source_code_hash : null

  # Image-based
  image_uri = var.image_uri

  # Only required for ZIP-based functions
  runtime = var.image_uri == null ? var.runtime : null
  handler = var.image_uri == null ? var.handler : null

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  layers = var.layers
  tags   = var.tags
}
