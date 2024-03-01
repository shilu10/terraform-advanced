variable "name" {
  description = "Name of the IAM Role"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON encoded assume role trust policy"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# AWS Managed Policies (Attach by ARN)
variable "attach_managed_policies" {
  description = "Whether to attach AWS-managed policies to the role"
  type        = bool
  default     = true
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

# Inline Policies
variable "create_inline_policies" {
  description = "Whether to create and attach inline policies to the role"
  type        = bool
  default     = true
}

variable "inline_policies" {
  description = "List of inline policies to attach to the IAM role"
  type = list(object({
    name       = string
    statements = list(any)
  }))
  default = []
}

# Custom Managed Policies
variable "create_custom_policies" {
  description = "Whether to create custom managed policies and attach them to the role"
  type        = bool
  default     = true
}

variable "custom_managed_policies" {
  description = "List of custom managed policies to create and attach"
  type = list(object({
    name        = string
    description = string
    path        = string
    statements  = list(any)
  }))
  default = []
}
