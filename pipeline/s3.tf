resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.project_name}-pipeline-artifacts"
}