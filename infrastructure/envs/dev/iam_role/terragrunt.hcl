include {
  path = find_in_parent_folders("root.hcl")
}


terraform {
  source = "../../../modules/iam_role"
}


input = {
    name = "lambda-sqs-role"

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
    Environment = "dev"
    Team        = "platform"
  }

  # AWS managed policies
  attach_managed_policies = true
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  # Inline policy
  create_inline_policies = true
  inline_policies = [
    {
      name = "inline-sqs-access"
      statements = [
        {
          Effect = "Allow"
          Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
          Resource = "arn:aws:sqs:us-east-1:123456789012:my-queue"
        }
      ]
    }
  ]

  # Custom managed policy
  create_custom_policies = true
  custom_managed_policies = [
    {
      name        = "custom-sqs-policy"
      path        = "/"
      description = "Custom policy to access SQS queue"
      statements = [
        {
          Effect = "Allow"
          Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage"]
          Resource = "arn:aws:sqs:us-east-1:123456789012:my-queue"
        }
      ]
    }
  ]
}