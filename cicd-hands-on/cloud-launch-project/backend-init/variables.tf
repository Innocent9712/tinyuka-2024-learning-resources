# variables.tf for backend-init

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-2"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state. This must be globally unique."
  type        = string
  # Example: "my-terraform-project-state-bucket"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  type        = string
  # Example: "my-terraform-project-locks"
}
