include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/iam_role"
}

dependency "sqs" {
  config_path = "../sqs"

  mock_outputs = {
    queue_arn = "arn:aws:sqs:us-east-1:000000000000:demo-queue"
  }
}

dependency "s3" {
  config_path = "../s3"

  mock_outputs = {
    bucket_arn = "arn:aws:s3:::my-upload-bucket"
  }
}

inputs = {
  name = "image-upload-iam-role-prod"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name               = "image-uploader-lambda-iam-prod"
    Project            = "terraform-secure-pipeline"
    Environment        = "prod"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }

  attach_managed_policies = true
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  create_inline_policies = true
  inline_policies = [
    {
      name = "inline-sqs-access"
      statements = [
        {
          Effect   = "Allow"
          Action   = ["sqs:SendMessage", "sqs:GetQueueUrl", "sqs:GetQueueAttributes"]
          Resource = dependency.sqs.outputs.queue_arn
        }
      ]
    },
    {
      name = "inline-cloudwatch-logs"
      statements = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*"
        }
      ]
    },

    {
      name = "inline-s3-access"
      statements = [
        {
          Effect   = "Allow"
          Action   = [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "${dependency.s3.outputs.bucket_arn}/*"
        }
      ]
    }
  ]
}
