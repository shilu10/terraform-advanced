include "parent" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/sqs"
}

inputs = {
  name                        = "uploads-sqs-terraform-secure-pipeline-stage"
  fifo_queue                  = true
  content_based_deduplication = true

  visibility_timeout_seconds = 45
  message_retention_seconds  = 86400
  delay_seconds              = 0
  max_message_size           = 131072
  receive_wait_time_seconds  = 10

  kms_master_key_id = "alias/aws/sqs"

  tags = {
    Name               = "uploads-sqs-terraform-secure-pipeline-stage"
    Project            = "terraform-secure-pipeline"
    Environment        = "stage"
    Owner              = "shilash"
    Team               = "devops"
    ManagedBy          = "terraform"
    Compliance         = "internal"
  }
}
