resource "aws_iam_role" "lambda_exec" {
  count = var.create_role ? 1 : 0

  name = "${var.name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  count = var.create_role && var.attach_basic_execution_role ? 1 : 0

  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.name

  role = var.create_role ? aws_iam_role.lambda_exec[0].arn : var.role_arn

  package_type = var.use_image ? "Image" : "Zip"

  # ZIP-based
  filename         = var.use_image == false ? var.filename : null
  s3_bucket        = var.use_image == false ? var.s3_bucket : null
  s3_key           = var.use_image == false ? var.s3_key : null
  source_code_hash = var.use_image == false ? var.source_code_hash : null
  runtime          = var.use_image == false ? var.runtime : null
  handler          = var.use_image == false ? var.handler : null
  layers           = var.use_image == false ? var.layers : null

  # Image-based
  image_uri = var.use_image == true ? var.image_uri : null

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.custom_vpc_enabled ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = var.tags
}

resource "aws_lambda_function_url" "this" {
  count              = var.enable_function_url ? 1 : 0
  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_auth_type

  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_lambda_permission" "allow_public_url" {
  count         = var.enable_function_url && var.function_url_auth_type == "NONE" ? 1 : 0

  statement_id  = "AllowPublicFunctionUrl"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.this.function_name
  principal     = "*"
}

# lambda event-source mapper
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count = var.enabled_event_source_mapping ? 1 : 0
  event_source_arn  = var.event_sourc_arn
  function_name     = aws_lambda_function.this.function_name
  batch_size        = 10
  enabled           = true
}
