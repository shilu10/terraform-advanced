output "rds_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "RDS instance endpoint"
}

output "rds_instance_id" {
  value       = aws_db_instance.this.id
  description = "RDS instance ID"
}

output "rds_arn" {
  value       = aws_db_instance.this.arn
  description = "ARN of RDS instance"
}
