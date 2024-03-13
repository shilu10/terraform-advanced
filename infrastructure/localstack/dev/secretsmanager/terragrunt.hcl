include {
    path = find_in_parent_folders("root.hcl")
}


dependency "rds" {
  config_path = "../rds"
    mock_outputs = {
        #host     = split(":", "rds-instance-endpoint.localstack.cloud:4566")[0]
        #port    = 5432  
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
    secret_name = "dev-secret-tf-advanced"
    secret_value = jsonencode({
        host = split(":", dependency.rds.outputs.rds_endpoint)[0]
        port = split(":", dependency.rds.outputs.rds_endpoint)[1]
        username = "admin"
        password = "S3cur3Pa$$w0rd"
        dbname   = "myappdb"
  })

    tags = {
        Name              = "dev-secret-tf-advanced"
        Project            = "iac-pipeline"
        Environment        = "dev"
        Owner              = "shilash"
        Team               = "devops"
        ManagedBy          = "terraform"
        Compliance         = "internal"
    }
}