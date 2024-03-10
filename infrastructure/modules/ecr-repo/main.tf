locals {
  aws_ecr_repos                 = var.private_repository ? var.ecr_private_repositories_values : {}
  aws_ecr_public_repos         = var.public_repository ? var.ecr_public_repositories_values : {}

  aws_ecr_repos_with_policy    = { for k, v in local.aws_ecr_repos : k => v if v.repository_policy != null }
  aws_ecr_repos_with_lifecycle = { for k, v in local.aws_ecr_repos : k => v if v.lifecycle_policy != null }
  aws_ecr_public_repos_with_policy = { for k, v in local.aws_ecr_public_repos : k => v if v.repository_policy != null }
}

resource "aws_ecr_repository" "this" {
  for_each = local.aws_ecr_repos

  name                 = "${var.repo_name_prefix}${each.value.name}${var.repo_name_suffix}"
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.encryption_type == "KMS" ? each.value.kms_key : null
  }

  lifecycle {
    ignore_changes = [
      image_tag_mutability,
      encryption_configuration[0].kms_key,
    ]
  }

  tags = each.value.tags
}

resource "aws_ecr_repository_policy" "this" {
  for_each = local.aws_ecr_repos_with_policy

  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.repository_policy
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = local.aws_ecr_repos_with_lifecycle

  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.lifecycle_policy
}

resource "aws_ecrpublic_repository" "this" {
  for_each = local.aws_ecr_public_repos

  repository_name = "${var.repo_name_prefix}${each.value.name}${var.repo_name_suffix}"

  lifecycle {
    # Nothing to ignore for now
  }

  tags = each.value.tags
}

resource "aws_ecrpublic_repository_policy" "this" {
  for_each = local.aws_ecr_public_repos_with_policy

  repository_name = aws_ecrpublic_repository.this[each.key].repository_name
  policy          = each.value.repository_policy
}
