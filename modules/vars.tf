variable "project_name" {
  type        = string
  default     = "rest-api"
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  default     = "qa"
  description = "Environment"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "Region where should be resources deployed"
}

variable "rest_api_port" {
  type        = number
  default     = 8080
  description = "The port rest-api is listening on"
}

variable "start_port_rds" {
  type        = number
  default     = 3306
  description = "From port"
}

variable "end_port_rds" {
  type        = number
  default     = 3306
  description = "To port"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/21"
  description = "CIDR block for the VPC"
}