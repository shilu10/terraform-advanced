include {
    path = find_in_parent_folders("root.localstack.hcl")
}

terraform {
    source = "../../../modules/ecr-repo"
}

inputs = {
    bucket_name = "tf-state-stage-localstack"
    dynamodb_table_name = "tf-state-lock-stage-localstack"
    force_destroy = true
    tags = {    
        Environment = "stage"
        Project = "terraform-advanced"
        Owner = "devops-team"
        ManagedBy = "Terragrunt"
        CreatedBy = "Terragrunt"
    }
}