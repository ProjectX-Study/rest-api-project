variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}