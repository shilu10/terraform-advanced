variable "name" {
  type        = string
  description = "Name of the SQS queue (without .fifo)"
  default     = "my-default-queue"
}

variable "fifo_queue" {
  type        = bool
  default     = false
  description = "Whether to create a FIFO queue"
}

variable "content_based_deduplication" {
  type        = bool
  default     = false
  description = "Enables content-based deduplication for FIFO queues"
}

variable "visibility_timeout_seconds" {
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  type        = number
  default     = 345600  # 4 days
}

variable "delay_seconds" {
  type        = number
  default     = 0
}

variable "max_message_size" {
  type        = number
  default     = 262144  # 256 KB
}

variable "receive_wait_time_seconds" {
  type        = number
  default     = 0
}

variable "kms_master_key_id" {
  type        = string
  default     = null  # Optional KMS encryption
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  default     = 300  # AWS default: 300 seconds (5 mins)
}

variable "redrive_policy" {
  type = object({
    deadLetterTargetArn = string
    maxReceiveCount     = number
  })
  default     = null
  description = "Redrive policy for dead-letter queues"
}

variable "tags" {
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "sqs-module"
  }
}
