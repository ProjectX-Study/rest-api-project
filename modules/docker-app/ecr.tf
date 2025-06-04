data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "rest_api_ecr_repository" {
  name = "${var.project_name}-${var.stage}-ecr-repository"
  tags = {
    Name = "${var.project_name}-${var.stage}-rest-api-repository"
  }
}

resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {

    command = <<-EOT
      cd ${path.module}
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
      docker build -t ${aws_ecr_repository.rest_api_ecr_repository.name} .
      docker tag ${aws_ecr_repository.rest_api_ecr_repository.name} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.rest_api_ecr_repository.name}
      docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.rest_api_ecr_repository.name}
    EOT
  }

  depends_on = [aws_ecr_repository.rest_api_ecr_repository]
}
