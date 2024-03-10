output "ecr_private_repository_urls" {
  description = "Private ECR repository URLs"
  value = var.private_repository ? {
    for key, repo in aws_ecr_repository.this :
    key => repo.repository_url
  } : {}
}


output "ecr_public_repository_uris" {
  description = "URIs of the public ECR repositories"
  value = var.public_repository ? {
    for key, repo in aws_ecrpublic_repository.this :
    key => repo.repository_uri
  } : {}
}


output "ecr_private_repos_with_policy" {
  description = "Private ECR repos with attached repository policy"
  value = var.private_repository ? keys(local.aws_ecr_repos_with_policy) : []
}


