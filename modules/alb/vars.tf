variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be created"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnets for ALB"
}

variable "rest_api_port" {
  type        = number
  description = "The port rest-api is listening on"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate for HTTPS"
}

variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "alb_security_group" {
  type        = string
  description = "Application load balancer's security group"
}