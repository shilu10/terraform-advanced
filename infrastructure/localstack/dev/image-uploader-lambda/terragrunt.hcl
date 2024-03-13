include "parent" {
  path = find_in_parent_folders("root.hcl")
}

dependency "iam_role" {
  config_path = "../image-uploader-lambda-iam-role"

  mock_outputs = {
    role_arn = "arn:aws:iam::000000000000:role/from-sqs-to-lambda"
  }
}

dependency "sqs" {
  config_path = "../sqs"

  mock_outputs = {
    queue_name = "my-app-queue.fifo"
  }
}

terraform {
  source = "../../../modules/lambda"
}

inputs = {
  name      = "image-upload-function"
  use_image = true
  image_uri = "000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566/image-uploader-lambda-dev-repo:latest"

  environment_variables = {
    SQS_REGION = "us-east-1"
    BUCKET_NAME = "demo-bucket"
    QUEUE_NAME = dependency.sqs.outputs.queue_name
  }

  custom_vpc_enabled = false

  # function url 
  enable_function_url = true

  create_role = false
  role_arn    = dependency.iam_role.outputs.role_arn

  tags = {
    Name               = "image-uploader-lambda"
    Project            = "iac-pipeline"
    Environment        = "dev"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}