include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name        = "uploads-terraform-secure-pipeline-stage"
  versioning_enabled = false

  tags = {
    Name               = "uploads-terraform-secure-pipeline-stage"
    Project            = "terraform-secure-pipeline"
    Environment        = "stage"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}
