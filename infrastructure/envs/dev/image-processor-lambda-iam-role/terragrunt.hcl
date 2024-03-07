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

dependency "rds" {
  config_path = "../rds"

  mock_outputs = {
    rds_arn = "arn:aws:rds:us-east-1:000000000000:rds-name"
  }
}

inputs = {
  name = "image-processor-iam-role"

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
    Name               = "image-processer-lambda-iam"
    Project            = "iac-pipeline"
    Environment        = "dev"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }

  # AWS managed policies
  attach_managed_policies = true
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  # Inline policies
  create_inline_policies = true
  inline_policies = [
    {
      name = "inline-sqs-access"
      statements = [
        {
          Effect   = "Allow"
          Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
          Resource = dependency.sqs.outputs.queue_arn
        }
      ]
    },
    {
      name = "inline-rds-access"
      statements = [
        {
          Effect   = "Allow"
          Action   = ["rds:DescribeDBInstances"]
          Resource = dependency.rds.outputs.rds_arn
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
    }
  ]
}
