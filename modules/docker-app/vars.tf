variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "region" {
  type        = string
  description = "Region where should be resources deployed"
}