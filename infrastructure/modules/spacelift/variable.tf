variable "stack_name" {
  type = string
}

variable "repository" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "project_root" {
  type = string
}

variable "terraform_version" {
  type    = string
  default = "1.6.6"
}

variable "description" {
  type    = string
  default = ""
}

variable "autodeploy" {
  type    = bool
  default = true
}

variable "administrative" {
  type    = bool
  default = false
}

variable "protect_from_deletion" {
  type    = bool
  default = false
}

variable "space_id" {
  type    = string
  default = "root"
}

variable "labels" {
  type    = list(string)
  default = []
}

variable "vcs_ignore_paths" {
  type    = list(string)
  default = []
}

variable "autostop" {
  type    = bool
  default = false
}

variable "enable_init" {
  type    = bool
  default = true
}

variable "runner_image" {
  type    = string
  default = "ghcr.io/gruntwork-io/terragrunt"
}

variable "worker_pool_id" {
  type    = string
  default = null
}


variable "manage_state" {
  type    = bool
  default = false # Required for Terragrunt
  
}

variable "enable_context_attachment" {
  type    = bool
  default = false
}

variable "context_ids" {
  type    = list(string)
  default = []
}

variable "enable_environment_variables" {
  type    = bool
  default = false
}

variable "enable_mounted_files" {
  type    = bool
  default = false
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "mounted_files" {
  type    = map(string)
  default = {}
}
