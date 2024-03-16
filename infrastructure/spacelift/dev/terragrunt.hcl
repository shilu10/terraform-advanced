include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
    source = "../../modules/spacelift"
}

inputs = {
  stack_name        = "uploads-stack-dev"
  stack_description = "Uploads stack for dev environment"
  raw_git_namespace = "uploads"
  repository        = "terraform-advanced"
  git_url           = "https://github.com/shilu10/terraform-advanced.git"
  branch            = "master"
  project_root      = "infrastructure/envs/dev/"
  labels            = ["terragrunt", "dev"]
  administrative    = false
  autodeploy        = true

  enable_terragrunt      = true
  terraform_version      = "~> 1.5.2"
  terragrunt_version     = "~> 0.52.0"
  use_run_all            = true
  use_smart_sanitization = true
  tool                   = "TERRAFORM_FOSS"

  use_github_enterprise = false

  attach_aws_role = false

  enable_drift_detection = false

}