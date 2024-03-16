# root.hcl for bootstrap which creates the backend and ecr repos 

locals {
    is_local = get_env("IS_BOOTSTRAP_LOCAL", true)
    region = "us-east-1"
}

generate "version"{
    path = "version.tf"
    if_exists = "overwrite"
    contents = <<EOF
terraform{
    required_providers{
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0
        }
    }
}
}
EOF
}

generate "provider"{
    path = "provider.tf"
    if_exists = "overwrite"
    contents = <<EOF
provider "aws"{
  region = local.region
}
}
EOF
}

locals {
  is_localstack = getenv("USE_LOCALSTACK") == "true"
}

remote_state {
  backend = local.is_localstack ? "local" : "s3"

  config = local.is_localstack ? {
    path = "${path_relative_to_include()}/terraform.tfstate"
  } : {
    bucket         = "tf-state-stage-terraform-secure-pipeline"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock-stage"
    encrypt        = true
  }
}
