include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  name     = "uploads-vpc-terraform-secure-pipeline-dev"
  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]

  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true


  security_groups = {
    "rds" = {
      name        = "uploads-rds-sg-terraform-secure-pipeline-dev"
      description = "Allow MySQL"
      ingress = [{
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }]
      egress = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }]
      tags = {
        Name               = "uploads-rds-sg-terraform-secure-pipeline-dev"
        Project            = "terraform-secure-pipeline"
        Environment        = "dev"
        Owner              = "shilash"
        Team               = "devops"
        ManagedBy          = "terraform"
        Compliance         = "internal"
      }
    }

    "lambda" = {
      name        = "uploads-lambda-sg-terraform-secure-pipeline-dev"
      description = "Allow All"
      ingress = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }]
      egress = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }]

      tags = {
        Name               = "uploads-lambda-sg-terraform-secure-pipeline-dev"
        Project            = "terraform-secure-pipeline"
        Environment        = "dev"
        Owner              = "shilash"
        Team               = "devops"
        ManagedBy          = "terraform"
        Compliance         = "internal"
      }
    }

  }

  tags = {
        Name               = "uploads-vpc-terraform-secure-pipeline-dev"
        Project            = "terraform-secure-pipeline"
        Environment        = "dev"
        Owner              = "shilash"
        Team               = "devops"
        ManagedBy          = "terraform"
        Compliance         = "internal"
      }
}