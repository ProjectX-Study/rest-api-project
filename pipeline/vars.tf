variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  type        = string
  description = "Project or company name"
}

variable "stage" {
  type        = string
  description = "Stage"
}

variable "codestar_connection_arn" {
  type = string
  description = "Codestar connection required for succesfull repository clone"
}