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
  rds = "http://localhost:4566"
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
    iam = "http://localhost:4566"
    lambda = "http://localhost:4566"
  }
}


module "lambda_image" {
  source = "../../../modules/lambda"

  name        = "image-fn"
  image_uri   = "000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566/demo-lambda:latest"
  timeout     = 30
  memory_size = 512

  environment_variables = {
    MODE = "container"
  }

  handler = null
  runtime = null

  tags = {
    App = "my-image-lambda"
  }
}
