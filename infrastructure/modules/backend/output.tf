output "s3_bucket" {
  value = aws_s3_bucket.this.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.this.name
}
