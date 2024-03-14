
include {
    path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../../modules/backend"
}

inputs = {
    bucket_name = "tf-state-stage-terraform-secure-pipeline"
    dynamodb_table_name = "tf-state-lock-stage"
    force_destroy = true
    tags = {
        Environment = "stage"
        Project     = "terraform-secure-pipeline"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}