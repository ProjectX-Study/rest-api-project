variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be created"
}

variable "rest_api_port" {
  type        = number
  description = "The port rest-api is listening on"
}

variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "start_port_rds" {
  type        = number
  description = "From port"
}

variable "end_port_rds" {
  type        = number
  description = "To port"
}