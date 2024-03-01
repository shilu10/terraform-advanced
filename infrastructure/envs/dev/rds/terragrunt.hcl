include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/rds"
}

inputs = {
  name                   = "mysql-db-dev"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = "myappdb"
  username               = "admin"
  password               = "S3cur3Pa$$w0rd"
  port                   = 3306
  subnet_ids             = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  multi_az               = false
  storage_type           = "gp3"
  backup_retention_period = 7
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name        = "mysql-db-prod"
    Environment = "production"
    Owner       = "devops-team"
  }
}