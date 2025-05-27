variable "vpc_id" {
  type        = string
  description = "VPC ID for RDS subnet group"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for RDS instances"
}

variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "rds_security_group" {
  type        = string
  description = "RDS database's security group"
}