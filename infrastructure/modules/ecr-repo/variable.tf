variable "private_repository" {
  type        = bool
  default     = false
  description = "Enable creation of private ECR repositories"
}

variable "public_repository" {
  type        = bool
  default     = false
  description = "Enable creation of public ECR repositories"
}

variable "repo_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix to add to all repository names"
}

variable "repo_name_suffix" {
  type        = string
  default     = ""
  description = "Suffix to add to all repository names"
}

variable "ecr_private_repositories_values" {
  type = map(object({
    name                 = string
    image_tag_mutability = string
    tags                 = map(string)
    repository_policy    = optional(string)
    lifecycle_policy     = optional(string)
    scan_on_push         = optional(bool, false)
    encryption_type      = optional(string, "AES256")
    kms_key              = optional(string)
    force_delete         = optional(bool, false)
  }))
  default = {}
  description = "Configuration for private ECR repositories"
}

variable "ecr_public_repositories_values" {
  type = map(object({
    name                 = string
    image_tag_mutability = optional(string)
    tags                 = map(string)
    repository_policy    = optional(string)
  }))
  default = {}
  description = "Configuration for public ECR repositories"
}
