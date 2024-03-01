output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "custom_policy_arns" {
  description = "List of ARNs of custom managed policies"
  value       = [for p in aws_iam_policy.custom : p.arn]
}
