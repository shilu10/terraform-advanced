include {
    path = find_in_parent_folders("root.localstack.hcl")
}

terraform{
    source = "../../../modules/ecr-repo"
}

inputs = {
    private_repository = true
    ecr_private_repositories_values = {
        dev_lambda_ecr_repo = {
            name                 = "image-processer-lambda-repo"
            image_tag_mutability = "MUTABLE"
            tags                 = {
                Environment = "dev"
                Project     = "terraform-advanced"
            }
            repository_policy    = null
            lifecycle_policy     = null
            scan_on_push         = true
            encryption_type      = "AES256"
            kms_key              = ""
            force_delete         = false
        }
    }
    tags = {
        Environment = "dev"
        Project     = "terraform-advanced"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}