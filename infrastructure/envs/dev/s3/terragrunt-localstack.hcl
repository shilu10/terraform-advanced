include "parent" {
  path = find_in_parent_folders("root-terragrunt.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name        = "demo-bucket"
  versioning_enabled = true

  tags = {
    Name               = "demo-bucket"
    Project            = "iac-pipeline"
    Environment        = "dev"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}
