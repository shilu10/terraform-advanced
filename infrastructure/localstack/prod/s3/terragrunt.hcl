include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name        = "uploads-terraform-secure-pipeline-prod"
  versioning_enabled = false

  tags = {
    Name               = "uploads-terraform-secure-pipeline-prod"
    Project            = "terraform-secure-pipeline"
    Environment        = "prod"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}
