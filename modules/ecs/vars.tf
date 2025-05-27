variable "vpc_id" {
  type        = string
  description = "VPC ID for ECS networking"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ECS tasks"
}

variable "database_subnet_ids" {
  type        = list(string)
  description = "List of database subnet IDs for ECS tasks"
}

variable "image_url" {
  type        = string
  description = "Full Docker image URL to run"
}

variable "rds_db_endpoint" {
  type        = string
  description = "RDS database endpoint for ECS container"
}

variable "project_name" {
  type        = string
  description = "Name of the project, platform or company"
}

variable "stage" {
  type        = string
  description = "Environment"
}

variable "rest_api_port" {
  type        = number
  description = "The port rest-api is listening on"
}

variable "alb_target_group" {
  type        = string
  description = "Application Load Balancer's target group"
}

variable "ecs_security_group" {
  type        = string
  description = "ECS's security group"
}