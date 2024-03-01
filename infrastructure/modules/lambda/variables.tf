variable "name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "use_image" {
  description = "Set to true if using container image-based deployment"
  type        = bool
  default     = false
}

variable "image_uri" {
  description = "ECR image URI for container-based Lambda"
  type        = string
  default     = null
}

variable "filename" {
  description = "Local ZIP file path for deployment"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket for ZIP file"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key for ZIP file"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  type        = string
  default     = null
}

variable "runtime" {
  description = "Lambda runtime (e.g. python3.10)"
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint (e.g. index.handler)"
  type        = string
  default     = null
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
  default     = {}
}

variable "attach_basic_execution_role" {
  description = "Whether to attach AWSLambdaBasicExecutionRole"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to attach Lambda to (if custom VPC is enabled)"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups for the Lambda (if custom VPC is enabled)"
  default     = []
}


variable "custom_vpc_enabled" {
  description = "Whether to deploy the Lambda into a custom VPC"
  type        = bool
  default     = false
}


variable "enable_function_url" {
  description = "Whether to create a Function URL for the Lambda"
  type        = bool
  default     = false
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
  default     = null
}

## event source mapper
variable "enabled_event_source_mapping" {
  description = "Optional bool for enabling event source mapper, making lambda to read from event source like sqs"
  type = bool 
  default = false
}

variable "event_source_arn" {
  description = "event source arn like sqs arn"
  default = ""
  type = string
}