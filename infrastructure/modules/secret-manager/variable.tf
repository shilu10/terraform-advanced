variable "secret_name" {
  type        = string
  description = "Name of the secret"
}

variable "secret_description" {
  type        = string
  default     = null
}

variable "secret_value" {
  type        = string
  sensitive   = true
  description = "Actual secret value as string (e.g., JSON)"
}

variable "kms_key_id" {
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  type        = number
  default     = 30
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "enable_rotation" {
  type    = bool
  default = false
}

variable "rotation_lambda_arn" {
  type    = string
  default = null
}

variable "rotation_schedule_expression" {
  type    = string
  default = "rate(30 days)"
}

variable "enable_policy" {
  type    = bool
  default = false
}

variable "secret_policy_json" {
  type        = string
  default     = ""
  description = "JSON IAM policy to attach to the secret (required if enable_policy = true)"
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.secret_description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags

  lifecycle {
    prevent_destroy = false
  }
}
