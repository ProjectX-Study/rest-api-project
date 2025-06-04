variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of public subnets for ALB"
}

variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "vpc_security_group" {
  type        = string
  description = "Security group for VPC Endpoints"
}

variable "region" {
  type        = string
  description = "Reegion of deployment"
}