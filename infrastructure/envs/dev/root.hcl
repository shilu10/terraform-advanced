# root.hcl - Terragrunt config with dynamic provider and backend


remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

# AWS provider config (dynamic via inputs)
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

locals {
  # Provide the AWS region dynamically via Terragrunt inputs or fallback
  aws_region = try(get_terragrunt_config().inputs.aws_region, "us-east-1")
}
