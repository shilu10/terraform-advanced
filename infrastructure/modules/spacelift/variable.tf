#############################
# Core Stack Configuration #
#############################

variable "git_url" {
  type        = string
  description = "Raw Git URL (e.g. https://github.com/...)"
}

variable "raw_git_namespace" {
  description = "Namespace label for Raw Git source"
  type        = string
}

variable "repository" {
  description = "just repo name"
  type        = string
}

variable "project_root" {
  description = "Subdirectory within repo"
  type        = string
  default     = "."
}

variable "additional_project_globs" {
  description = "Optional globs for additional project paths"
  type        = list(string)
  default     = []
}


variable "stack_name" {
  type        = string
  description = "Name of the Spacelift stack"
}

variable "stack_description" {
  type        = string
  description = "Description of the Spacelift stack"
}

variable "branch" {
  type        = string
  description = "VCS branch name"
}

variable "labels" {
  type        = list(string)
  default     = []
  description = "Labels for the stack"
}

variable "administrative" {
  type        = bool
  default     = false
  description = "Whether the stack can manage other stacks"
}

variable "autodeploy" {
  type        = bool
  default     = false
  description = "Enable autodeploy for the stack"
}

variable "space_id" {
  type        = string
  default     = "root"
  description = "Spacelift space ID"
}

variable "protect_from_deletion" {
  type        = bool
  default     = false
  description = "Prevent accidental deletion of the stack"
}

variable "terraform_external_state_access" {
  type        = bool
  default     = false
  description = "Enable external state access"
}

variable "terraform_smart_sanitization" {
  type        = bool
  default     = false
  description = "Enable smart sanitization for Terraform outputs"
}

variable "worker_pool_id" {
  type        = string
  default     = ""
  description = "ID of the Spacelift worker pool (for self-hosted runners)"
}

############################
# VCS & Terragrunt Options #
############################

variable "use_github_enterprise" {
  type        = bool
  default     = false
  description = "Use GitHub Enterprise integration"
}

variable "github_namespace" {
  type        = string
  default     = ""
  description = "GitHub organization/user for the repository"
}

variable "enable_terragrunt" {
  type        = bool
  default     = false
  description = "Enable Terragrunt block"
}

variable "terraform_version" {
  type        = string
  default     = "1.6.2"
  description = "Terraform version to use"
}

variable "terragrunt_version" {
  type        = string
  default     = "0.55.15"
  description = "Terragrunt version to use"
}

variable "use_run_all" {
  type        = bool
  default     = false
  description = "Use terragrunt run-all"
}

variable "use_smart_sanitization" {
  type        = bool
  default     = false
  description = "Enable smart sanitization in terragrunt"
}

variable "tool" {
  type        = string
  default     = "TERRAFORM_FOSS"
  description = "Terragrunt tool to use (TERRAFORM_FOSS, OPEN_TOFU, etc.)"
}

#######################
# Lifecycle Hooks     #
#######################

variable "after_apply" {
  type    = list(string)
  default = null
}
variable "after_destroy" {
  type    = list(string)
  default = null
}

variable "after_init" {
  type    = list(string)
  default = null
}

variable "after_plan" {
  type    = list(string)
  default = null
}

variable "after_perform" {
  type    = list(string)
  default = null
}

variable "after_run" {
  type    = list(string)
  default = null
}

variable "before_apply" {
  type    = list(string)
  default = null
}

variable "before_destroy" {
  type    = list(string)
  default = null
}

variable "before_init" {
  type    = list(string)
  default = null
}

variable "before_plan" {
  type    = list(string)
  default = null
}

variable "before_perform" {
  type    = list(string)
  default = null
}

variable "before_run" {
  type    = list(string)
  default = null
}


#######################
# AWS Role Attachment #
#######################

variable "attach_aws_role" {
  type        = bool
  default     = false
  description = "Whether to attach an AWS IAM role"
}

variable "aws_role_arn" {
  type        = string
  default     = ""
  description = "AWS IAM role ARN"
}


#######################
# Drift Detection     #
#######################

variable "enable_drift_detection" {
  type        = bool
  default     = false
  description = "Enable drift detection"
}

variable "drift_reconcile" {
  type        = bool
  default     = true
  description = "Automatically reconcile drift"
}

variable "drift_schedule" {
  type        = list(string)
  default     = null
  description = "Drift detection cron schedule"
}

#######################
# Policy Attachment   #
#######################

variable "policies" {
  type = map(object({
    type        = string
    space_id    = string
    policy_file = string
  }))
  default     = {}
  description = "Map of policy definitions"
}

## contexts
variable "contexts" {
  description = "Map of contexts with optional env vars and mounted files"
  type = map(object({
    description   = string
    env_vars = optional(object({
      name        = string
      value       = string
      write_only  = bool
      description = string
    }))
    mounted_file = optional(object({
      relative_path = string
      local_path    = string
    }))
  }))
}

## security email
variable "enable_security_email" {
  type = bool
  default = false
}

variable "security_email_addr" {
  type = string
  default = "dummy@gmail.com"
}