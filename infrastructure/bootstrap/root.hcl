
generate "version" {
  path = "version.tf"
  if_exists = "overwrite_terragrunt"
   contents  = <<EOF
terraform {
  required_version >= "1.4.0"
  
  required_providers {
     aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
}
}}
