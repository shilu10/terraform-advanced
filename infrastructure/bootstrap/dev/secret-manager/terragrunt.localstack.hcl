include {
    path = find_in_parent_folders("root.localstack.hcl")
}

terraform {
    source = "../../../modules/secret-manager"
}

inputs = {
    secret_name = "dev-secret"
    secret_value = {
        username = "dev_user"
        password = "dev_password"
    }
    tags = {
        Environment = "dev"
        Project     = "terraform-advanced"
    }
}