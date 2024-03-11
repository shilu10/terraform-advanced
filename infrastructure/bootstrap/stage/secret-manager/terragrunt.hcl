include {
    path = find_in_parent_folders("root-localstack.hcl")
}

terraform {
    source = "../../../modules/secret-manager"
}

inputs = {
    secret_name = "stage-secret"
    secret_value = {
        username = "stage_user"
        password = "stage_password"
    }
    tags = {
        Environment = "stage"
        Project     = "terraform-advanced"
    }
}