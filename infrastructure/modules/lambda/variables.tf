variable "name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "my-lambda-function"
}

variable "use_image" {
  description = "Set to true if using container image-based deployment"
  type        = bool
  default     = false
}

variable "image_uri" {
  description = "ECR image URI for container-based Lambda"
  type        = string
  default     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda-image:latest"
}

variable "filename" {
  description = "Local ZIP file path for deployment"
  type        = string
  default     = "lambda.zip"
}

variable "s3_bucket" {
  description = "S3 bucket for ZIP file"
  type        = string
  default     = "my-lambda-artifacts"
}

variable "s3_key" {
  description = "S3 key for ZIP file"
  type        = string
  default     = "lambda.zip"
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda runtime (e.g. python3.10)"
  type        = string
  default     = "python3.10"
}

variable "handler" {
  description = "Function entrypoint (e.g. index.handler)"
  type        = string
  default     = "main.handler"
}

variable "layers" {
  description = "Optional Lambda layers"
  type        = list(string)
  default     = []
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Memory allocated to Lambda in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the Lambda"
  type        = map(string)
  default     = {
    ENV = "dev"
  }
}

variable "attach_basic_execution_role" {
  description = "Whether to attach AWSLambdaBasicExecutionRole"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "lambda-demo"
    Environment = "dev"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to attach Lambda to (if custom VPC is enabled)"
  default     = ["subnet-abc123", "subnet-def456"]
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups for the Lambda (if custom VPC is enabled)"
  default     = ["sg-0123456789abcdef0"]
}

variable "custom_vpc_enabled" {
  description = "Whether to deploy the Lambda into a custom VPC"
  type        = bool
  default     = false
}

variable "enable_function_url" {
  description = "Whether to create a Function URL for the Lambda"
  type        = bool
  default     = true
}

variable "function_url_auth_type" {
  description = "Auth type for the Lambda Function URL (e.g., NONE or AWS_IAM)"
  type        = string
  default     = "NONE"
}

variable "create_role" {
  description = "Whether the module should create an IAM role for Lambda execution"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "Optional ARN of an existing IAM role to use instead of creating one"
  type        = string
  default     = ""
}

variable "enabled_event_source_mapping" {
  description = "Optional bool for enabling event source mapper, making lambda read from event source like SQS"
  type        = bool
  default     = false
}

variable "event_source_arn" {
  description = "Event source ARN like SQS ARN"
  type        = string
  default     = "arn:aws:sqs:us-east-1:123456789012:my-queue"
}
