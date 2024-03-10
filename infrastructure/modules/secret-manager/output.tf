# output.tf for secret-manager module 

output "secret_id"{
    value = aws_secretsmanager_secret.this.id
    description = "ID of the created secret"
}

output "secret_arn" {
    value = aws_secretsmanager_secret.this.arn
    description = "ARN of the created secret"
}

output "secret_rotation_enabled"{
    value = aws_secretsmanager_secret_rotation.this.rotation_enabled
    description = "value indicating if secret rotation is enabled"
}

output "secret_version_id" {
    value = aws_secretsmanager_secret_version.this.id
    description = "ID of the secret version"
}