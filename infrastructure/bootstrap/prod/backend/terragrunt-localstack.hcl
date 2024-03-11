
include {
    path = find_in_parent_folders("root-localstack.hcl")
}

terraform {
    source = "../../../modules/backend"
}

inputs = {
    bucket_name = "tf-state-prod-localstack"
    dynamodb_table_name = "tf-state-lock-prod-localstack"
    force_destroy = true
    tags = {
        Environment = "prod"
        Project     = "terraform-advanced"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}