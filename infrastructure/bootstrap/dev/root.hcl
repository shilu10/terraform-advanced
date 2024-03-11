# root.hcl - Terragrunt config with dynamic provider and backend

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
