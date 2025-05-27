output "repository_name" {
  value = aws_ecr_repository.rest_api_ecr_repository.name
}

output "repository_url" {
  value = aws_ecr_repository.rest_api_ecr_repository.repository_url
}

output "image_url" {
  value = "${aws_ecr_repository.rest_api_ecr_repository.repository_url}:latest"
}
