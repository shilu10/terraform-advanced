output "rds_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "RDS instance endpoint"
}

output "rds_instance_id" {
  value       = aws_db_instance.this.id
  description = "RDS instance internal resource ID (not DBInstanceIdentifier)"
}

output "rds_arn" {
  value       = aws_db_instance.this.arn
  description = "ARN of RDS instance"
}

output "rds_identifier" {
  value       = aws_db_instance.this.identifier
  description = "DBInstanceIdentifier of RDS instance (use this for API calls)"
}
