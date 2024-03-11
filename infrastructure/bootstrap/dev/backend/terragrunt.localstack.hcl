
include {
    path = find_in_parent_folders("root.localstack.hcl")
}

terraform {
    source = "../../../modules/backend"
}

inputs = {
    bucket_name = "tf-state-dev-localstack"
    dynamodb_table_name = "tf-state-lock-dev-localstack"
    force_destroy = true
    tags = {
        Environment = "dev"
        Project     = "terraform-advanced"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}