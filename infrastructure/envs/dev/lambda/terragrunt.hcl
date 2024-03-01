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
}