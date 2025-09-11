variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_arn" {
  description = "ARN of the VPC"
  type        = string
}

variable "public_bucket" {
  description = "Name of the public S3 bucket"
  type        = string
}

variable "private_bucket" {
  description = "Name of the private S3 bucket"
  type        = string
}

variable "visible_bucket" {
  description = "Name of the visible S3 bucket"
  type        = string
}
