include {
    path = find_in_parent_folders("root.hcl")
}



dependency "iam_role" {
  config_path = "../image-uploader-lambda-iam-role"

  mock_outputs = {
    role_arn = "arn:aws:iam::000000000000:role/from-sqs-to-lambda"
  }
}

terraform {
  source = "../../../modules/lambda"
}

inputs = {
    name                 = "image-upload-function"
    use_image            = true
    image_uri            = "000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566/demo-lambda:latest"

    environment_variables = {
        ENV = "dev"
    }

    custom_vpc_enabled   = false

    # function url 
    enable_function_url = true 

    create_role = false 
    role_arn = dependency.iam_role.outputs.role_arn
}