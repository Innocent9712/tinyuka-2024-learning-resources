# terraform.tf (Backend configuration - initially local)
terraform {
  required_version = ">= 1.0"

  # Initial local backend - comment out after migration
  backend "local" {
    path = "terraform.tfstate"
  }

  # Remote backend - uncomment after migration
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "infrastructure/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
