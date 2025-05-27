# Optional for more flexibility, though not required for basic VPC setup
variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/21"
  description = "CIDR block for the VPC"
}

variable "subnet_prefix" {
  type        = string
  default     = 24
  description = "Prefix size for each subnet"
}

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
  default     = 2
}