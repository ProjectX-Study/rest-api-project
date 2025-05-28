resource "aws_iam_role" "pipeline_role" {
  name               = "${var.project_name}-${var.stage}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codestar_policy.json
}

resource "aws_iam_role_policy_attachment" "managed_policy_arns" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "codestar_policy" {
  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection_arn]
  }
}

resource "aws_codebuild_project" "docker" {
  name          = "${var.project_name}-docker"
  service_role  = aws_iam_role.pipeline_role.arn
  build_timeout = 15

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/buildspecs/docker"
  }
}

resource "aws_codebuild_project" "tf_plan" {
  name         = "${var.project_name}-terraform-plan"
  service_role = aws_iam_role.pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/buildspecs/tf_plan"
  }
}

resource "aws_codebuild_project" "tf_apply" {
  name         = "${var.project_name}-terraform-apply"
  service_role = aws_iam_role.pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/buildspecs/tf_apply"
  }
}

resource "aws_codebuild_project" "api_test" {
  name         = "${var.project_name}-test"
  service_role = aws_iam_role.pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/buildspecs/api_test"
  }
}

resource "aws_codepipeline" "rest-api-pipeline" {
  name          = "${var.project_name}-deploy"
  role_arn      = var.codestar_connection_arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "2"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "${var.project_name}"
        BranchName           = "main"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Docker_Build"
    action {
      name             = "Build_and_Push"
      category         = "Build"
      owner            = "AWS"
      version          = "2"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["docker_output"]

      configuration = {
        ProjectName = var.project_name
        Stage       = var.stage
      }
    }
  }

  stage {
    name = "Terraform_Plan"
    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      version          = "2"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]

      configuration = {
        ProjectName = var.project_name
        Stage       = var.stage
      }
    }
  }

  stage {
    name = "Approve"
    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      version  = "2"
      provider = "Manual"
    }
  }

  stage {
    name = "Terraform_Apply"
    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      version         = "2"
      provider        = "CodeBuild"
      input_artifacts = ["plan_output"]

      configuration = {
        ProjectName = var.project_name
        Stage       = var.stage
      }
    }
  }

  stage {
    name = "Test"
    action {
      name            = "ConnectivityTest"
      category        = "Build"
      owner           = "AWS"
      version         = "2"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = var.project_name
        Stage       = var.stage
      }
    }
  }
}
