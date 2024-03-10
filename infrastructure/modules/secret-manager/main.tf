resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.secret_description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_value
}

resource "aws_secretsmanager_secret_rotation" "this" {
  count                  = var.enable_rotation ? 1 : 0
  secret_id              = aws_secretsmanager_secret.this.id
  rotation_lambda_arn    = var.rotation_lambda_arn
  rotation_rules {
    schedule_expression = var.rotation_schedule_expression
  }
}

resource "aws_secretsmanager_secret_policy" "this" {
  count      = var.enable_policy ? 1 : 0
  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = var.secret_policy_json
}