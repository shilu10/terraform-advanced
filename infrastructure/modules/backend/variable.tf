variable "bucket_name" {
  description = "Name of the S3 bucket to be used for the backend"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

variable "force_destroy" {
  description = "Force destroy the S3 bucket on deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
