variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-default-s3-bucket"
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "s3-module"
  }
}
