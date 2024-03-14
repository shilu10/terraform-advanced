include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/rds"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-111111", "subnet-222222"]
    security_group_ids = {
      rds = "sg-12345678"
    }
  }

}

inputs = {
  name                  = "uploads-db-stage"
  engine                = "mysql"
  engine_version        = "8.0.35"
  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  max_allocated_storage = 100
  db_name               = get_env("STAGE_UPLOADS_DB_NAME", "my-upload-db")
  username              = get_env("STAGE_UPLOADS_DB_USERNAME", "dummy")
  password              = get_env("STAGE_UPLOADS_DB_PASSWORD", "dummy")
  port                  = get_env("STAGE_UPLOADS_DB_PORT", 3306)

  subnet_ids             = dependency.vpc.outputs.private_subnet_ids
  vpc_security_group_ids = [dependency.vpc.outputs.security_group_ids["rds"]]

  multi_az                = false
  storage_type            = "gp3"
  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name               = "uploads-db-stage"
    Project            = "terraform-secure-pipeline"
    Environment        = "stage"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}
