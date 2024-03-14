
include {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../modules/backend"
}

inputs = {
    bucket_name = "tf-state-prod-terraform-secure-pipeline"
    dynamodb_table_name = "tf-state-lock-prod"
    force_destroy = true
    tags = {
        Environment = "prod"
        Project     = "terraform-secure-pipeline"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}