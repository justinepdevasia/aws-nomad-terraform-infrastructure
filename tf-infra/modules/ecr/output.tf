output "repository_urls" {
  value = {
    for repo in aws_ecr_repository.ecr_repo : repo.name => repo.repository_url
  }
}