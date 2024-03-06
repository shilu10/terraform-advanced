variable "name" {
  description = "Name of the IAM Role"
  type        = string
  default     = "my-iam-role"
}

variable "assume_role_policy" {
  description = "JSON encoded assume role trust policy"
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    "Environment" = "dev"
    "ManagedBy"   = "terraform"
  }
}

variable "attach_managed_policies" {
  description = "Whether to attach AWS-managed policies to the role"
  type        = bool
  default     = true
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]
}

variable "create_inline_policies" {
  description = "Whether to create and attach inline policies to the role"
  type        = bool
  default     = false
}

variable "inline_policies" {
  description = "List of inline policies to attach to the IAM role"
  type = list(object({
    name       = string
    statements = list(any)
  }))
  default = []
}

variable "create_custom_policies" {
  description = "Whether to create custom managed policies and attach them to the role"
  type        = bool
  default     = false
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
