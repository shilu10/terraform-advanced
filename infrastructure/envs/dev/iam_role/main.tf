provider "aws" {

  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"


  # only required for non virtual hosted-style endpoint use case.
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#s3_use_path_style
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

   endpoints  {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}


module "lambda_iam_role" {
  source = "../../../modules/iam_role"  # path to your module

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
