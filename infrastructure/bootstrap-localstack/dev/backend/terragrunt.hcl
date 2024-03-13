
include {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../modules/backend"
}

inputs = {
    bucket_name = "tf-state-dev-terraform-advanced"
    dynamodb_table_name = "tf-state-lock-dev"
    force_destroy = true
    tags = {
        Environment = "dev"
        Project     = "terraform-advanced"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}