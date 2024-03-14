output "stack_id" {
  description = "ID of the created Spacelift stack"
  value       = spacelift_stack.this.id
}

output "stack_name" {
  description = "Name of the stack"
  value       = spacelift_stack.this.name
}

output "context_id" {
  description = "ID of the created context (if any)"
  value       = try(spacelift_context.this[0].id, null)
}

output "aws_role_attached" {
  description = "Whether an AWS role was attached"
  value       = var.attach_aws_role
}