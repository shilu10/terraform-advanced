output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "lambda_function_url" {
  description = "The URL to invoke the Lambda Function (if enabled)"
  value       = var.enable_function_url ? aws_lambda_function_url.this[0].function_url : null
}
