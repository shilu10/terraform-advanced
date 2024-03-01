include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket_name        = "demo-bucket"
  versioning_enabled  = true
  
  tags = {
    Environment = "dev"
  }
}
