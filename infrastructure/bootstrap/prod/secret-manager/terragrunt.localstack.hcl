include {
    path = find_in_parent_folders("root.localstack.hcl")
}

terraform {
    source = "../../../modules/secret-manager"
}

inputs = {
    secret_name = "prod-secret"
    secret_value = {
        username = "prod_user"
        password = "prod_password"
    }
    tags = {
        Environment = "prod"
        Project     = "terraform-advanced"
    }
}