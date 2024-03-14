
include {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../modules/backend"
}

inputs = {
    bucket_name = "tf-state-dev-terraform-secure-pipeline"
    dynamodb_table_name = "tf-state-lock-dev"
    force_destroy = true
    tags = {
        Environment = "dev"
        Project     = "terraform-secure-pipeline"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}