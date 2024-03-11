include {
    path = find_in_parent_folders("root.localstack.hcl")
}

terraform {
    source = "../../../modules/ecr-repo"
}

inputs = {
    private_repository = true
    ecr_private_repositories_values = {
        image_processer_lambda_repo = {
            name                 = "image-processer-lambda-stage-repo"
            image_tag_mutability = "MUTABLE"
            tags                 = {
                Environment = "stage"
                Project     = "terraform-advanced"
            }
            repository_policy    = null
            lifecycle_policy     = null
            scan_on_push         = true
            encryption_type      = "AES256"
            kms_key              = ""
            force_delete         = false
        },
        image_uploader_lambda_repo = {
            name                 = "image-uploader-lambda-stage-repo"
            image_tag_mutability = "MUTABLE"
            tags                 = {
                Environment = "stage"
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
        Environment = "stage"
        Project     = "terraform-advanced"
        Owner       = "devops-team"
        ManagedBy   = "Terragrunt"
        CreatedBy   = "Terragrunt"
    }
}