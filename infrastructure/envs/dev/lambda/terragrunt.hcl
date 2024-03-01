include {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-111111", "subnet-222222"]
    security_group_ids = {
      lambda = "sg-12345678"
    }
  }
}

dependency "sqs" {
  config_path = "../sqs"

  mock_outputs = {
    queue_arn = ["arn:aws:sqs:us-east-1:000000000000:demo-queue"]
  }
}

terraform {
  source = "../../../modules/lambda"
}


inputs = {
    name                 = "my-image-function"
    use_image            = true
    image_uri            = "000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566/demo-lambda:latest"

    environment_variables = {
        ENV = "prod"
        }
    custom_vpc_enabled   = true

    subnet_ids             = dependency.vpc.outputs.private_subnet_ids
    security_group_ids = [dependency.vpc.outputs.security_group_ids["lambda"]]

    # function url 
    enable_function_url = true 

    # event souurce (pull based lambda)
    enabled_event_source_mapping = true 
    event_source_arn = dependency.sqs.outputs.queue_arn

    create_role = false 
    role_arn = "arn:aws:iam::000000000000:role/from-sqs-to-lambda"
}