
resource "aws_sqs_queue" "this" {
  name                      = var.fifo_queue ? "${var.name}.fifo" : var.name
  fifo_queue                = var.fifo_queue
  content_based_deduplication = var.fifo_queue && var.content_based_deduplication

  visibility_timeout_seconds       = var.visibility_timeout_seconds
  message_retention_seconds        = var.message_retention_seconds
  delay_seconds                    = var.delay_seconds
  max_message_size                 = var.max_message_size
  receive_wait_time_seconds        = var.receive_wait_time_seconds
  kms_master_key_id                = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  redrive_policy = var.redrive_policy != null ? jsonencode(var.redrive_policy) : null

  tags = var.tags
}
