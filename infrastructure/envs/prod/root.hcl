# root.hcl - Terragrunt config with dynamic provider and backend

remote_state {
  backend = "s3"
  config = {
    bucket         = "tf-state-prod-terraform-secure-pipeline"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-state-lock-prod"
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

# version block file 
generate "version" {
  path      = "version.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
}