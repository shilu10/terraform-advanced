include {
    path = find_in_parent_folders("root.hcl")
}


dependency "rds" {
  config_path = "../rds"
    mock_outputs = {
        rds_endpoint = "rds-instance-endpoint.localstack.cloud:4566"
        username = "mock_db_username"
        password = "mock_db_password"
        dbname = "mock_db_name"
    }
}


terraform {
  source = "../../../modules/secret-manager"
}

inputs = {
    secret_name = "upload-db-secret-terraform-secure-pipeline-prod"
    secret_value = jsonencode({
        host = split(":", dependency.rds.outputs.rds_endpoint)[0]
        port = split(":", dependency.rds.outputs.rds_endpoint)[1]
        username = get_env("PROD_UPLOADS_DB_USERNAME")
        password = get_env("PROD_UPLOADS_DB_PASSWORD")
        dbname   = get_env("PROD_UPLOADS_DB_NAME")
  })

    tags = {
        Name              = "upload-db-secret-terraform-secure-pipeline-prod"
        Project            = "terraform-secure-pipeline"
        Environment        = "prod"
        Owner              = "shilash"
        Team               = "devops"
        ManagedBy          = "terraform"
        Compliance         = "internal"
    }
}