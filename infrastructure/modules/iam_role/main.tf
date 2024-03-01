resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

resource "aws_iam_role_policy" "inline" {
  for_each = {
    for p in var.inline_policies : p.name => p
    if var.create_inline_policies && length(var.inline_policies) > 0
  }

  name   = each.value.name
  role   = aws_iam_role.this.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = each.value.statements
  })
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = (
    var.attach_managed_policies && length(var.managed_policy_arns) > 0
      ? toset(var.managed_policy_arns)
      : toset([])
  )

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_policy" "custom" {
  for_each = {
    for p in var.custom_managed_policies : p.name => p
    if var.create_custom_policies && length(var.custom_managed_policies) > 0
  }

  name        = each.value.name
  path        = each.value.path
  description = each.value.description
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = each.value.statements
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "custom_attach" {
  for_each = (
    var.create_custom_policies && length(var.custom_managed_policies) > 0
      ? { for name, res in aws_iam_policy.custom : name => res.arn }
      : {}
  )

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

