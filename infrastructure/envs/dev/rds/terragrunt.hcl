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
  name                  = "mysql-db-dev"
  engine                = "mysql"
  engine_version        = "8.0.35"
  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  max_allocated_storage = 100
  db_name               = "myappdb"
  username              = "admin"
  password              = "S3cur3Pa$$w0rd"
  port                  = 3306

  subnet_ids             = dependency.vpc.outputs.private_subnet_ids
  vpc_security_group_ids = [dependency.vpc.outputs.security_group_ids["rds"]]

  multi_az                = false
  storage_type            = "gp3"
  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name        = "mysql-db-prod"
    Environment = "production"
    Owner       = "devops-team"
  }
}
