module "pipeline" {
  source = "./pipeline"
  project_name = "rest-api"
  stage = "qa"
  codestar_connection_arn = "arn:aws:codestar-connections:eu-west-1:111111111111:connection/aaaaa-bbbbbbbb-cccccccc-dddddddd"
  region = "eu-west-1"
}

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "rest-api-backend1"
    key    = "rest-api/backend.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}