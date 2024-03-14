include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name        = "uploads-terraform-secure-pipeline-dev"
  versioning_enabled = false

  tags = {
    Name               = "uploads-terraform-secure-pipeline-dev"
    Project            = "terraform-secure-pipeline"
    Environment        = "dev"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}
